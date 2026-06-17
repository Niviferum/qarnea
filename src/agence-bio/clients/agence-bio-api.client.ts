import { Injectable, Logger } from '@nestjs/common';

export interface OperateurBioApi {
  numeroBio: string;
  raisonSociale: string;
  siret?: string;
  adressesPrincipales: {
    lieu?: string;
    codePostal?: string;
    ville?: string;
    departementLabel?: string;
  }[];
  produits: unknown[];
  activites: unknown[];
  organismeCertificateur?: { nom: string };
}

export interface PageOperateursBio {
  items: OperateurBioApi[];
  pagination: { page: number; pageSize: number; totalCount: number };
}

const BASE_URL = 'https://opendata.agencebio.org/api/gouv/operateurs/';
const PAGE_SIZE = 100;

@Injectable()
export class AgenceBioApiClient {
  private readonly logger = new Logger(AgenceBioApiClient.name);

  async fetchPage(departement: string, page: number): Promise<PageOperateursBio> {
    const params = new URLSearchParams({
      departement,
      page: String(page),
      pageSize: String(PAGE_SIZE),
      categories: 'P',
    });

    const url = `${BASE_URL}?${params.toString()}`;
    this.logger.debug(`GET ${url}`);

    const response = await fetch(url, {
      headers: { Accept: 'application/json' },
    });

    if (!response.ok) {
      throw new Error(`Agence Bio API error: ${response.status} ${response.statusText}`);
    }

    return response.json() as Promise<PageOperateursBio>;
  }
}
