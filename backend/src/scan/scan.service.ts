import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma, SourceScan, StatutVerification } from '../generated/prisma';
import { OpenFoodFactsApiClient, OffProduct } from './clients/openfoodfacts-api.client';
import { ScannerProduitDto } from './dto/scanner-produit.dto';
import { HistoriqueScanDto } from './dto/historique-scan.dto';
import { estOrigineAnimale } from './utils/origine-animale.util';

const TAGS_BIO = ['en:organic', 'fr:bio'];

function grade(valeur: string | undefined): string | null {
  // colonne Prisma en db.Char(1) : toute valeur OFF qui n'est pas une seule
  // lettre (unknown, not-applicable, futures variantes de taxonomie...) est ignoree
  if (!valeur) return null;
  const lettre = valeur.toUpperCase();
  return /^[A-Z]$/.test(lettre) ? lettre : null;
}

@Injectable()
export class ScanService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly offApi: OpenFoodFactsApiClient,
  ) {}

  async scannerProduit(idUtilisateur: string, dto: ScannerProduitDto) {
    const produit = await this.offApi.fetchProduct(dto.code_barre);

    if (!produit) {
      throw new NotFoundException(
        `Produit ${dto.code_barre} introuvable sur Open Food Facts`,
      );
    }

    const categoriesTags = produit.categories_tags ?? [];

    const scan = await this.prisma.produitScanne.create({
      data: {
        id_utilisateur: idUtilisateur,
        code_barre: dto.code_barre,
        nom_produit: produit.product_name ?? null,
        marque: produit.brands ?? null,
        categorie: produit.categories?.split(',')[0]?.trim() ?? null,
        date_scan: new Date(),
        donnees_off: produit as unknown as Prisma.InputJsonValue,
        nutriscore: grade(produit.nutriscore_grade),
        score_nova: produit.nova_group ?? null,
        ecoscore: grade(produit.ecoscore_grade),
        nombre_additifs: produit.additives_n ?? produit.additives_tags?.length ?? 0,
        allergenes: (produit.allergens_tags ?? []) as Prisma.InputJsonValue,
        origines_ingredients: (produit.origins_tags ?? []) as Prisma.InputJsonValue,
        label_bio: this.estLabelBio(produit.labels_tags),
        localisation_scan_lat: dto.localisation_scan_lat ?? null,
        localisation_scan_lng: dto.localisation_scan_lng ?? null,
        source_donnees: SourceScan.open_food_facts,
      },
    });

    return { ...scan, origine_animale: estOrigineAnimale(categoriesTags) };
  }

  async getHistorique(idUtilisateur: string, query: HistoriqueScanDto) {
    const { page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;
    const where: Prisma.ProduitScanneWhereInput = { id_utilisateur: idUtilisateur };

    const [data, total] = await Promise.all([
      this.prisma.produitScanne.findMany({
        where,
        skip,
        take: limit,
        orderBy: { date_scan: 'desc' },
      }),
      this.prisma.produitScanne.count({ where }),
    ]);

    return { data, total, page, limit };
  }

  async getScanParId(idUtilisateur: string, idProduitScanne: string) {
    const scan = await this.prisma.produitScanne.findFirst({
      where: { id_produit_scanne: idProduitScanne, id_utilisateur: idUtilisateur },
    });

    if (!scan) {
      throw new NotFoundException(`Scan ${idProduitScanne} introuvable`);
    }

    return scan;
  }

  async getAlternatives(idUtilisateur: string, idProduitScanne: string) {
    const scan = await this.prisma.produitScanne.findFirst({
      where: { id_produit_scanne: idProduitScanne, id_utilisateur: idUtilisateur },
      select: { donnees_off: true },
    });

    if (!scan) {
      throw new NotFoundException(`Scan ${idProduitScanne} introuvable`);
    }

    const donnees = scan.donnees_off as Record<string, unknown> | null;
    const categoriesTags = Array.isArray(donnees?.['categories_tags'])
      ? (donnees['categories_tags'] as string[])
      : [];

    if (!categoriesTags.length) return [];

    const types = await this.prisma.typeProduction.findMany({
      where: { off_categories_tags: { hasSome: categoriesTags } },
      select: {
        nom: true,
        producteurs: {
          where: {
            producteur: {
              visible_publiquement: true,
              statut_verification: StatutVerification.verified,
            },
          },
          select: {
            producteur: {
              select: {
                id_producteur: true,
                nom_exploitation: true,
                ville: true,
                description: true,
                telephone: true,
                email_contact: true,
                site_web: true,
                vente_directe: true,
                vente_paniers: true,
                livraison_possible: true,
                rayon_livraison_km: true,
                coordonnees_lat: true,
                coordonnees_lng: true,
                types_production: {
                  select: { type_production: { select: { nom: true } } },
                },
              },
            },
          },
        },
      },
    });

    const seen = new Set<string>();
    const results: { type_produit_equivalent: string; producteur: unknown }[] = [];

    for (const type of types) {
      for (const { producteur } of type.producteurs) {
        if (!seen.has(producteur.id_producteur)) {
          seen.add(producteur.id_producteur);
          results.push({ type_produit_equivalent: type.nom, producteur });
        }
      }
    }

    return results;
  }

  private estLabelBio(labelsTags: OffProduct['labels_tags']): boolean {
    if (!labelsTags) return false;
    return labelsTags.some((tag) => TAGS_BIO.includes(tag));
  }
}
