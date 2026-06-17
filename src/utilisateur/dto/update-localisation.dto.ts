import { IsNumber, IsBoolean, IsOptional, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateLocalisationDto {
  @ApiProperty({ example: 45.748 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  localisation_lat: number;

  @ApiProperty({ example: 4.847 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  localisation_lng: number;

  @ApiPropertyOptional({ example: true })
  @IsBoolean()
  @IsOptional()
  localisation_autorisee?: boolean;
}
