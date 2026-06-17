import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { StatutVerification } from '../../generated/prisma';

export class VerifierProducteurDto {
  @ApiProperty({ enum: StatutVerification, example: 'verified' })
  @IsEnum(StatutVerification)
  statut_verification: StatutVerification;

  @ApiPropertyOptional({ example: 'SIRET invalide' })
  @IsString()
  @IsOptional()
  @MaxLength(300)
  note_admin?: string;
}
