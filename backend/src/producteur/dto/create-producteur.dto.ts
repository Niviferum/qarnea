import {
  IsString,
  IsOptional,
  IsBoolean,
  IsNumber,
  IsArray,
  IsEmail,
  IsEnum,
  IsObject,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { RayonFloutage } from '../../generated/prisma';

export class CreateProducteurDto {
  @ApiProperty({ example: 'Ferme du Soleil' })
  @IsString()
  @MaxLength(100)
  nom_exploitation: string;

  @ApiProperty({ example: 'Ferme du Soleil SARL' })
  @IsString()
  @MaxLength(100)
  raison_sociale: string;

  @ApiProperty({ example: '12345678901234' })
  @IsString()
  @MaxLength(14)
  siret: string;

  @ApiProperty({ example: 'Maraîcher bio depuis 2010, spécialisé légumes de saison.' })
  @IsString()
  @MaxLength(300)
  description: string;

  @ApiPropertyOptional({ example: 'Agriculture raisonnée, zéro pesticide.' })
  @IsString()
  @IsOptional()
  @MaxLength(300)
  description_pratiques?: string;

  @ApiProperty({ example: '15 chemin des Vignes' })
  @IsString()
  @MaxLength(50)
  adresse_ligne1: string;

  @ApiPropertyOptional({ example: 'Lieu-dit La Croix' })
  @IsString()
  @IsOptional()
  @MaxLength(50)
  adresse_ligne2?: string;

  @ApiProperty({ example: 'Rennes' })
  @IsString()
  @MaxLength(50)
  ville: string;

  @ApiProperty({ example: 'Bretagne' })
  @IsString()
  @MaxLength(50)
  region: string;

  @ApiProperty({ example: 'Ille-et-Vilaine' })
  @IsString()
  @MaxLength(50)
  departement: string;

  @ApiProperty({ example: 48.1173 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  @Type(() => Number)
  coordonnees_lat: number;

  @ApiProperty({ example: -1.6778 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  @Type(() => Number)
  coordonnees_lng: number;

  @ApiPropertyOptional({ default: true })
  @IsBoolean()
  @IsOptional()
  afficher_adresse_exacte?: boolean;

  @ApiPropertyOptional({ enum: RayonFloutage })
  @IsEnum(RayonFloutage)
  @IsOptional()
  rayon_floutage_km?: RayonFloutage;

  @ApiProperty({ example: '0612345678' })
  @IsString()
  @MaxLength(20)
  telephone: string;

  @ApiProperty({ example: 'contact@ferme-du-soleil.fr' })
  @IsEmail()
  @MaxLength(50)
  email_contact: string;

  @ApiPropertyOptional({ example: 'https://ferme-du-soleil.fr' })
  @IsString()
  @IsOptional()
  @MaxLength(50)
  site_web?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  @MaxLength(50)
  facebook_url?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  @MaxLength(50)
  instagram_url?: string;

  @ApiProperty({
    description: 'Horaires par jour',
    example: { lundi: '9h-12h', mardi: 'fermé', mercredi: '9h-18h' },
  })
  @IsObject()
  horaires_ouverture: Record<string, unknown>;

  @ApiPropertyOptional({ example: 'Marché de Rennes le samedi matin' })
  @IsString()
  @IsOptional()
  @MaxLength(300)
  jours_marches?: string;

  @ApiProperty()
  @IsBoolean()
  vente_directe: boolean;

  @ApiProperty()
  @IsBoolean()
  vente_paniers: boolean;

  @ApiProperty()
  @IsBoolean()
  livraison_possible: boolean;

  @ApiPropertyOptional({ example: 30 })
  @IsNumber()
  @IsOptional()
  @Min(0)
  @Type(() => Number)
  rayon_livraison_km?: number;

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  click_and_collect?: boolean;

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  commande_en_ligne?: boolean;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  photo_profil_url?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  photos_exploitation?: string[];

  @ApiPropertyOptional({ example: '12345', description: 'Numéro BIO Agence Bio (optionnel)' })
  @IsString()
  @IsOptional()
  @MaxLength(20)
  numero_bio?: string;
}
