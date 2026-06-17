import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma, Utilisateur } from '../generated/prisma';
import { CreateProducteurDto } from './dto/create-producteur.dto';
import { UpdateProducteurDto } from './dto/update-producteur.dto';
import { QueryProducteursDto, NearbyQueryDto } from './dto/query-producteurs.dto';
import { VerifierProducteurDto } from './dto/verifier-producteur.dto';

const CHAMPS_LISTE = {
  id_producteur: true,
  nom_exploitation: true,
  ville: true,
  region: true,
  departement: true,
  coordonnees_lat: true,
  coordonnees_lng: true,
  vente_directe: true,
  vente_paniers: true,
  livraison_possible: true,
  rayon_livraison_km: true,
  click_and_collect: true,
  photo_profil_url: true,
  statut_verification: true,
  types_production: {
    select: { type_production: { select: { nom: true, slug: true } } },
  },
  labels: {
    select: { label: { select: { nom: true, code: true, logo_url: true } } },
  },
};

const CHAMPS_DETAIL = {
  ...CHAMPS_LISTE,
  id_utilisateur: true,
  visible_publiquement: true,
  raison_sociale: true,
  description: true,
  description_pratiques: true,
  adresse_ligne1: true,
  adresse_ligne2: true,
  telephone: true,
  email_contact: true,
  site_web: true,
  facebook_url: true,
  instagram_url: true,
  horaires_ouverture: true,
  jours_marches: true,
  rayon_floutage_km: true,
  afficher_adresse_exacte: true,
  photos_exploitation: true,
  numero_bio: true,
  date_creation: true,
  date_modification: true,
};

@Injectable()
export class ProducteurService {
  constructor(private readonly prisma: PrismaService) {}

  async soumettre(user: Utilisateur, dto: CreateProducteurDto) {
    const existant = await this.prisma.producteur.findUnique({
      where: { id_utilisateur: user.id_utilisateur },
    });

    if (existant) {
      throw new ConflictException('Cet utilisateur possede deja une fiche producteur');
    }

    return this.prisma.producteur.create({
      data: {
        ...dto,
        horaires_ouverture: dto.horaires_ouverture as Prisma.InputJsonValue,
        id_utilisateur: user.id_utilisateur,
        statut_verification: 'pending',
      },
    });
  }

  async findPublics(query: QueryProducteursDto) {
    const { page = 1, limit = 20, ville, region, livraison_possible, vente_directe } = query;

    const where: Prisma.ProducteurWhereInput = {
      visible_publiquement: true,
      statut_verification: 'verified',
      ...(ville && { ville }),
      ...(region && { region }),
      ...(livraison_possible !== undefined && { livraison_possible }),
      ...(vente_directe !== undefined && { vente_directe }),
    };

    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      this.prisma.producteur.findMany({ where, skip, take: limit, select: CHAMPS_LISTE }),
      this.prisma.producteur.count({ where }),
    ]);

    return { data, total, page, limit };
  }

  async findNearby(query: NearbyQueryDto) {
    const { lat, lng, rayon_km = 30 } = query;
    const rayonMetres = rayon_km * 1000;

    type RawRow = {
      id_producteur: string;
      nom_exploitation: string;
      ville: string;
      coordonnees_lat: number;
      coordonnees_lng: number;
      distance_m: number;
    };

    const rows = await this.prisma.$queryRaw<RawRow[]>`
      SELECT
        p.id_producteur,
        p.nom_exploitation,
        p.ville,
        p.coordonnees_lat,
        p.coordonnees_lng,
        ST_Distance(
          ST_MakePoint(p.coordonnees_lng, p.coordonnees_lat)::geography,
          ST_MakePoint(${lng}, ${lat})::geography
        ) AS distance_m
      FROM producteur p
      WHERE
        p.visible_publiquement = true
        AND p.statut_verification = 'verified'
        AND ST_DWithin(
          ST_MakePoint(p.coordonnees_lng, p.coordonnees_lat)::geography,
          ST_MakePoint(${lng}, ${lat})::geography,
          ${rayonMetres}
        )
      ORDER BY distance_m ASC
      LIMIT 50
    `;

    return rows.map((r) => ({ ...r, distance_km: Math.round(r.distance_m / 100) / 10 }));
  }

  async findById(id: string) {
    const producteur = await this.prisma.producteur.findUnique({
      where: { id_producteur: id },
      select: CHAMPS_DETAIL,
    });

    if (!producteur || !producteur.visible_publiquement) {
      throw new NotFoundException('Producteur introuvable');
    }

    return producteur;
  }

  async findMien(userId: string) {
    const producteur = await this.prisma.producteur.findUnique({
      where: { id_utilisateur: userId },
      select: CHAMPS_DETAIL,
    });

    if (!producteur) {
      throw new NotFoundException('Fiche producteur introuvable');
    }

    return producteur;
  }

  async mettreAJour(userId: string, dto: UpdateProducteurDto) {
    const producteur = await this.prisma.producteur.findUnique({
      where: { id_utilisateur: userId },
    });

    if (!producteur) {
      throw new NotFoundException('Fiche producteur introuvable');
    }

    return this.prisma.producteur.update({
      where: { id_producteur: producteur.id_producteur },
      data: {
        ...dto,
        ...(dto.horaires_ouverture !== undefined && {
          horaires_ouverture: dto.horaires_ouverture as Prisma.InputJsonValue,
        }),
      } as Prisma.ProducteurUncheckedUpdateInput,
      select: CHAMPS_DETAIL,
    });
  }

  async verifier(id: string, dto: VerifierProducteurDto, admin: Utilisateur) {
    if (admin.role !== 'admin') {
      throw new ForbiddenException('Acces reserve aux administrateurs');
    }

    const producteur = await this.prisma.producteur.findUnique({
      where: { id_producteur: id },
    });

    if (!producteur) {
      throw new NotFoundException('Producteur introuvable');
    }

    return this.prisma.producteur.update({
      where: { id_producteur: id },
      data: {
        statut_verification: dto.statut_verification,
        note_admin: dto.note_admin,
        id_admin_verificateur: admin.id_utilisateur,
        date_verification: new Date(),
      },
    });
  }
}
