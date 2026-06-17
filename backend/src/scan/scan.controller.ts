import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { ScanService } from './scan.service';
import { ScannerProduitDto } from './dto/scanner-produit.dto';
import { HistoriqueScanDto } from './dto/historique-scan.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Utilisateur } from '../generated/prisma';

@ApiTags('scan')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('scan')
export class ScanController {
  constructor(private readonly scanService: ScanService) {}

  @Post()
  @ApiOperation({ summary: 'Scanner un produit via son code-barre (Open Food Facts)' })
  @ApiResponse({ status: 201, description: 'Produit scanne et enregistre' })
  @ApiResponse({ status: 404, description: 'Produit introuvable sur Open Food Facts' })
  scannerProduit(
    @Body() dto: ScannerProduitDto,
    @Request() req: { user: Utilisateur },
  ) {
    return this.scanService.scannerProduit(req.user.id_utilisateur, dto);
  }

  @Get('historique')
  @ApiOperation({ summary: 'Historique des scans de l\'utilisateur connecte' })
  @ApiResponse({ status: 200, description: 'Liste paginee retournee' })
  getHistorique(@Query() query: HistoriqueScanDto, @Request() req: { user: Utilisateur }) {
    return this.scanService.getHistorique(req.user.id_utilisateur, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detail d\'un scan de l\'utilisateur connecte' })
  @ApiResponse({ status: 200, description: 'Scan retourne' })
  @ApiResponse({ status: 404, description: 'Scan introuvable' })
  getScanParId(
    @Param('id', ParseUUIDPipe) id: string,
    @Request() req: { user: Utilisateur },
  ) {
    return this.scanService.getScanParId(req.user.id_utilisateur, id);
  }

  @Get(':id/alternatives')
  @ApiOperation({ summary: 'Alternatives locales pour un scan' })
  @ApiResponse({ status: 200, description: 'Liste des alternatives retournee' })
  @ApiResponse({ status: 404, description: 'Scan introuvable' })
  getAlternatives(
    @Param('id', ParseUUIDPipe) id: string,
    @Request() req: { user: Utilisateur },
  ) {
    return this.scanService.getAlternatives(req.user.id_utilisateur, id);
  }
}
