import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class RechercheOperateursDto {
  @ApiPropertyOptional({ description: 'Recherche textuelle sur raison sociale ou ville' })
  @IsString()
  @IsOptional()
  q?: string;

  @ApiPropertyOptional({ example: 'Ille-et-Vilaine' })
  @IsString()
  @IsOptional()
  departement?: string;

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
