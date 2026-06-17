import { Injectable, Logger } from '@nestjs/common';

export interface GeocodageResult {
  lat: number;
  lng: number;
  score: number;
}

interface AdresseFeature {
  geometry: { type: string; coordinates: [number, number] };
  properties: { score: number };
}

interface AdresseResponse {
  features: AdresseFeature[];
}

const BASE_URL = 'https://api-adresse.data.gouv.fr/search/';
const SCORE_MIN = 0.5;

@Injectable()
export class AdresseApiClient {
  private readonly logger = new Logger(AdresseApiClient.name);

  async geocoder(adresse: string, codePostal?: string): Promise<GeocodageResult | null> {
    const q = codePostal ? `${adresse} ${codePostal}` : adresse;
    const params = new URLSearchParams({ q, limit: '1' });
    const url = `${BASE_URL}?${params.toString()}`;

    this.logger.debug(`GET ${url}`);

    const response = await fetch(url, {
      headers: { Accept: 'application/json' },
    });

    if (!response.ok) {
      this.logger.warn(`API Adresse error: ${response.status} for query "${q}"`);
      return null;
    }

    const data = (await response.json()) as AdresseResponse;
    const feature = data.features?.[0];

    if (!feature || feature.properties.score < SCORE_MIN) {
      return null;
    }

    const [lng, lat] = feature.geometry.coordinates;
    return { lat, lng, score: feature.properties.score };
  }
}
