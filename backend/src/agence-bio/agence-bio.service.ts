import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma } from '../generated/prisma';
import { AgenceBioApiClient } from './clients/agence-bio-api.client';
import { AdresseApiClient } from './clients/adresse-api.client';
import { RechercheOperateursDto } from './dto/recherche-operateurs.dto';

@Injectable()
export class AgenceBioService {
  private readonly logger = new Logger(AgenceBioService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly agenceBioApi: AgenceBioApiClient,
    private readonly adresseApi: AdresseApiClient,
  ) {}

  async rechercherOperateurs(query: RechercheOperateursDto) {
    const { page = 1, limit = 20, departement, q } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.AgenceBioOperateurWhereInput = {
      ...(departement && { departement }),
      ...(q && {
        OR: [
          { raison_sociale: { contains: q, mode: 'insensitive' } },
          { ville: { contains: q, mode: 'insensitive' } },
        ],
      }),
    };

    const [data, total] = await Promise.all([
      this.prisma.agenceBioOperateur.findMany({ where, skip, take: limit }),
      this.prisma.agenceBioOperateur.count({ where }),
    ]);

    return { data, total, page, limit };
  }

  async findByNumeroBio(numero_bio: string) {
    const operateur = await this.prisma.agenceBioOperateur.findUnique({
      where: { numero_bio },
    });

    if (!operateur) {
      throw new NotFoundException(`Operateur BIO ${numero_bio} introuvable dans le cache`);
    }

    return operateur;
  }

  async syncDepartement(departement: string): Promise<number> {
    this.logger.log(`Sync Agence Bio — departement ${departement}`);
    let total = 0;
    let page = 0;

    const firstPage = await this.agenceBioApi.fetchPage(departement, page);
    const { pageSize, totalCount } = firstPage.pagination;
    const totalPages = Math.ceil(totalCount / pageSize);

    await this.upsertPage(firstPage.items);
    total += firstPage.items.length;

    for (page = 1; page < totalPages; page++) {
      const { items } = await this.agenceBioApi.fetchPage(departement, page);
      await this.upsertPage(items);
      total += items.length;
    }

    this.logger.log(`Sync terminee : ${total} operateurs pour le departement ${departement}`);
    return total;
  }

  async geocoderNonGeocodes(limit: number): Promise<number> {
    const operateurs = await this.prisma.agenceBioOperateur.findMany({
      where: { geocodage_effectue: false },
      take: limit,
    });

    let geocodes = 0;

    for (const op of operateurs) {
      if (!op.adresse && !op.code_postal) continue;

      const resultat = await this.adresseApi.geocoder(
        op.adresse ?? '',
        op.code_postal ?? undefined,
      );

      if (!resultat) continue;

      await this.prisma.agenceBioOperateur.update({
        where: { numero_bio: op.numero_bio },
        data: {
          coordonnees_lat: resultat.lat,
          coordonnees_lng: resultat.lng,
          geocodage_effectue: true,
        },
      });

      geocodes++;
    }

    return geocodes;
  }

  private async upsertPage(
    items: Awaited<ReturnType<AgenceBioApiClient['fetchPage']>>['items'],
  ) {
    for (const op of items) {
      const adresse = op.adressesPrincipales?.[0];
      await this.prisma.agenceBioOperateur.upsert({
        where: { numero_bio: op.numeroBio },
        create: {
          numero_bio: op.numeroBio,
          raison_sociale: op.raisonSociale,
          siret: op.siret ?? null,
          adresse: adresse?.lieu ?? null,
          code_postal: adresse?.codePostal ?? null,
          ville: adresse?.ville ?? null,
          departement: adresse?.departementLabel ?? null,
          produits_certifies: op.produits as Prisma.InputJsonValue,
          activites: op.activites as Prisma.InputJsonValue,
          organisme_certificateur: op.organismeCertificateur?.nom ?? null,
        },
        update: {
          raison_sociale: op.raisonSociale,
          siret: op.siret ?? null,
          adresse: adresse?.lieu ?? null,
          code_postal: adresse?.codePostal ?? null,
          ville: adresse?.ville ?? null,
          departement: adresse?.departementLabel ?? null,
          produits_certifies: op.produits as Prisma.InputJsonValue,
          activites: op.activites as Prisma.InputJsonValue,
          organisme_certificateur: op.organismeCertificateur?.nom ?? null,
        },
      });
    }
  }
}
