import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiProperty,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { IsInt, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { AgenceBioService } from './agence-bio.service';
import { RechercheOperateursDto } from './dto/recherche-operateurs.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Utilisateur } from '../generated/prisma';

class SyncDepartementDto {
  @ApiProperty({ example: '35', description: 'Code departement INSEE' })
  @IsString()
  departement: string;
}

class GeocoderDto {
  @ApiProperty({ default: 50, minimum: 1, maximum: 500 })
  @IsInt()
  @Min(1)
  @Max(500)
  @Type(() => Number)
  limit: number = 50;
}

@ApiTags('agence-bio')
@Controller('agence-bio')
export class AgenceBioController {
  constructor(private readonly agenceBioService: AgenceBioService) {}

  @Get('operateurs')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Rechercher dans le cache Agence Bio' })
  @ApiResponse({ status: 200, description: 'Liste paginee retournee' })
  rechercherOperateurs(@Query() query: RechercheOperateursDto) {
    return this.agenceBioService.rechercherOperateurs(query);
  }

  @Get('operateurs/:numero_bio')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Detail d\'un operateur BIO' })
  @ApiResponse({ status: 200, description: 'Operateur retourne' })
  @ApiResponse({ status: 404, description: 'Operateur introuvable' })
  findByNumeroBio(@Param('numero_bio') numero_bio: string) {
    return this.agenceBioService.findByNumeroBio(numero_bio);
  }

  @Post('sync')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Synchroniser un departement depuis l\'API Agence Bio (admin)' })
  @ApiBody({ type: SyncDepartementDto })
  @ApiResponse({ status: 200, description: 'Nombre d\'operateurs synchronises' })
  async syncDepartement(
    @Body() dto: SyncDepartementDto,
    @Request() _req: { user: Utilisateur },
  ) {
    const total = await this.agenceBioService.syncDepartement(dto.departement);
    return { synced: total, departement: dto.departement };
  }

  @Post('geocoder')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Geocoder les operateurs sans coordonnees (admin)' })
  @ApiBody({ type: GeocoderDto })
  @ApiResponse({ status: 200, description: 'Nombre d\'operateurs geocodes' })
  async geocoderNonGeocodes(
    @Body() dto: GeocoderDto,
    @Request() _req: { user: Utilisateur },
  ) {
    const total = await this.agenceBioService.geocoderNonGeocodes(dto.limit);
    return { geocoded: total };
  }
}
