import { Injectable, Logger } from '@nestjs/common';

export interface OperateurBioApi {
  numeroBio: number;
  raisonSociale: string;
  siret?: string;
  adressesOperateurs: {
    lieu?: string;
    codePostal?: string;
    ville?: string;
    lat?: number;
    long?: number;
    active?: boolean;
  }[];
  productions: { code: string; nom: string }[];
  activites: unknown[];
  organismeCertificateur?: { nom: string };
}

export interface PageOperateursBio {
  items: OperateurBioApi[];
  pagination: { page: number; pageSize: number; totalCount: number };
}

const BASE_URL = 'https://opendata.agencebio.org/api/gouv/operateurs/';
const PAGE_SIZE = 20; // API caps at 20 items per page regardless of pageSize param

@Injectable()
export class AgenceBioApiClient {
  private readonly logger = new Logger(AgenceBioApiClient.name);

  async fetchPage(departement: string, page: number): Promise<PageOperateursBio> {
    const params = new URLSearchParams({
      departements: departement,
      debut: String(page * PAGE_SIZE),
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

    const raw = (await response.json()) as { nbTotal: string; items: OperateurBioApi[] };
    return {
      items: raw.items,
      pagination: {
        page,
        pageSize: PAGE_SIZE,
        totalCount: parseInt(raw.nbTotal, 10),
      },
    };
  }
}
