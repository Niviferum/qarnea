import {
  IsString,
  IsOptional,
  IsBoolean,
  IsInt,
  IsDateString,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProfilDto {
  @ApiPropertyOptional({ example: 'Dupont', maxLength: 100 })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  nom?: string;

  @ApiPropertyOptional({ example: 'Jean', maxLength: 100 })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  prenom?: string;

  @ApiPropertyOptional({ example: '0612345678', maxLength: 20 })
  @IsString()
  @IsOptional()
  @MaxLength(20)
  telephone?: string;

  @ApiPropertyOptional({ example: '1990-05-15' })
  @IsDateString()
  @IsOptional()
  date_naissance?: string;

  @ApiPropertyOptional({ example: 'Lyon', maxLength: 100 })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  ville_preferee?: string;

  @ApiPropertyOptional({ example: 30, minimum: 1, maximum: 200 })
  @IsInt()
  @IsOptional()
  @Min(1)
  @Max(200)
  rayon_recherche_defaut?: number;

  @ApiPropertyOptional({ example: 'fr', maxLength: 5 })
  @IsString()
  @IsOptional()
  @MaxLength(5)
  langue?: string;

  @ApiPropertyOptional({ example: true })
  @IsBoolean()
  @IsOptional()
  accepte_notifications?: boolean;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/avatar.jpg' })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  avatar_url?: string;
}
