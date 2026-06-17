import {
  IsOptional,
  IsBoolean,
  IsInt,
  IsNumber,
  IsString,
  IsNotEmpty,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';

export class QueryProducteursDto {
  @ApiPropertyOptional({ example: 'Rennes' })
  @IsString()
  @IsOptional()
  ville?: string;

  @ApiPropertyOptional({ example: 'Bretagne' })
  @IsString()
  @IsOptional()
  region?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  livraison_possible?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  vente_directe?: boolean;

  @ApiPropertyOptional({ default: 1, minimum: 1 })
  @IsInt()
  @IsOptional()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20, minimum: 1, maximum: 100 })
  @IsInt()
  @IsOptional()
  @Min(1)
  @Max(100)
  @Type(() => Number)
  limit?: number = 20;
}

export class NearbyQueryDto {
  @ApiProperty({ example: 48.1173, description: 'Latitude du point de recherche' })
  @IsNumber()
  @IsNotEmpty()
  @Type(() => Number)
  lat: number;

  @ApiProperty({ example: -1.6778, description: 'Longitude du point de recherche' })
  @IsNumber()
  @IsNotEmpty()
  @Type(() => Number)
  lng: number;

  @ApiPropertyOptional({ example: 30, default: 30, description: 'Rayon de recherche en km' })
  @IsInt()
  @IsOptional()
  @Min(1)
  @Max(200)
  @Type(() => Number)
  rayon_km?: number = 30;
}
