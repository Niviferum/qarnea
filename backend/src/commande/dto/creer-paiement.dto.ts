import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsPositive, IsString, IsUUID, Max, MaxLength } from 'class-validator';
import { Type } from 'class-transformer';

export class CreerPaiementDto {
  @ApiProperty({ example: 4.0, description: 'Prix TTC annoncé par le producteur (€)' })
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(9999)
  @Type(() => Number)
  prix_producteur: number;

  @ApiProperty({ example: 'Steak fermier Limousin 200g' })
  @IsString()
  @MaxLength(200)
  description: string;

  @ApiProperty({ example: 'uuid-producteur' })
  @IsUUID()
  id_producteur: string;
}
