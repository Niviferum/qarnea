import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsLatitude, IsLongitude, IsOptional, Matches } from 'class-validator';

export class ScannerProduitDto {
  @ApiProperty({
    example: '3017620422003',
    description: 'Code-barre EAN/UPC du produit scanne (8 a 14 chiffres)',
  })
  @Matches(/^\d{8,14}$/, {
    message: 'code_barre doit etre un code EAN/UPC valide (8 a 14 chiffres)',
  })
  code_barre: string;

  @ApiPropertyOptional({ description: 'Latitude au moment du scan (si geoloc autorisee)' })
  @IsOptional()
  @IsLatitude()
  localisation_scan_lat?: number;

  @ApiPropertyOptional({ description: 'Longitude au moment du scan (si geoloc autorisee)' })
  @IsOptional()
  @IsLongitude()
  localisation_scan_lng?: number;
}
