import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'jean.dupont@email.fr' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'motdepasse123', minLength: 8, maxLength: 100 })
  @IsString()
  @MinLength(8)
  @MaxLength(100)
  password: string;

  @ApiProperty({ example: 'Dupont', maxLength: 100 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nom: string;

  @ApiProperty({ example: 'Jean', maxLength: 100 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  prenom: string;

  @ApiPropertyOptional({ example: '0612345678', maxLength: 20 })
  @IsString()
  @IsOptional()
  @MaxLength(20)
  telephone?: string;
}
