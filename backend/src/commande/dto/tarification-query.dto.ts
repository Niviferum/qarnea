import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsNumber, IsPositive, Max } from 'class-validator';

export class TarificationQueryDto {
  @ApiProperty({ example: 4.0, description: 'Prix TTC annoncé par le producteur (€)' })
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(9999)
  @Type(() => Number)
  prix: number;
}
