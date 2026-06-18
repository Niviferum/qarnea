import { Injectable, Logger } from '@nestjs/common';

export interface OffProduct {
  product_name?: string;
  brands?: string;
  categories?: string;
  categories_tags?: string[];
  nutriscore_grade?: string;
  nova_group?: number;
  ecoscore_grade?: string;
  additives_n?: number;
  additives_tags?: string[];
  allergens_tags?: string[];
  origins_tags?: string[];
  labels_tags?: string[];
}

interface OffResponse {
  code: string;
  status: number;
  product?: OffProduct;
}

const BASE_URL = 'https://world.openfoodfacts.org/api/v2/product';
const FIELDS = [
  'product_name',
  'brands',
  'categories',
  'categories_tags',
  'nutriscore_grade',
  'nova_group',
  'ecoscore_grade',
  'additives_n',
  'additives_tags',
  'allergens_tags',
  'origins_tags',
  'labels_tags',
].join(',');

@Injectable()
export class OpenFoodFactsApiClient {
  private readonly logger = new Logger(OpenFoodFactsApiClient.name);

  async fetchProduct(codeBarre: string): Promise<OffProduct | null> {
    const url = `${BASE_URL}/${codeBarre}.json?fields=${FIELDS}`;
    this.logger.debug(`GET ${url}`);

    const response = await fetch(url, {
      headers: {
        Accept: 'application/json',
        'User-Agent': 'Qarnea/1.0 (contact@qarnea.app)',
      },
      signal: AbortSignal.timeout(8000),
    });

    if (response.status === 404) {
      return null;
    }

    if (!response.ok) {
      throw new Error(`OpenFoodFacts API error: ${response.status} ${response.statusText}`);
    }

    const data = (await response.json()) as OffResponse;

    if (data.status === 0 || !data.product) {
      return null;
    }

    return data.product;
  }
}
