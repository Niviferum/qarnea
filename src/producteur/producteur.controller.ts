import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ProducteurService } from './producteur.service';
import { CreateProducteurDto } from './dto/create-producteur.dto';
import { UpdateProducteurDto } from './dto/update-producteur.dto';
import { QueryProducteursDto, NearbyQueryDto } from './dto/query-producteurs.dto';
import { VerifierProducteurDto } from './dto/verifier-producteur.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Utilisateur } from '../generated/prisma';

@ApiTags('producteurs')
@Controller('producteurs')
export class ProducteurController {
  constructor(private readonly producteurService: ProducteurService) {}

  @Get()
  @ApiOperation({ summary: 'Liste des producteurs verifies (avec filtres et pagination)' })
  @ApiResponse({ status: 200, description: 'Liste paginee retournee' })
  findPublics(@Query() query: QueryProducteursDto) {
    return this.producteurService.findPublics(query);
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Producteurs a proximite (PostGIS)' })
  @ApiResponse({ status: 200, description: 'Liste des producteurs proches' })
  findNearby(@Query() query: NearbyQueryDto) {
    return this.producteurService.findNearby(query);
  }

  @Get('me')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Fiche du producteur connecte' })
  @ApiResponse({ status: 200, description: 'Fiche retournee' })
  @ApiResponse({ status: 404, description: 'Fiche introuvable' })
  findMien(@Request() req: { user: Utilisateur }) {
    return this.producteurService.findMien(req.user.id_utilisateur);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Fiche publique d\'un producteur' })
  @ApiResponse({ status: 200, description: 'Fiche retournee' })
  @ApiResponse({ status: 404, description: 'Producteur introuvable' })
  findById(@Param('id', ParseUUIDPipe) id: string) {
    return this.producteurService.findById(id);
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Soumettre une fiche producteur' })
  @ApiResponse({ status: 201, description: 'Fiche soumise, en attente de verification' })
  @ApiResponse({ status: 409, description: 'Fiche deja existante pour cet utilisateur' })
  soumettre(
    @Request() req: { user: Utilisateur },
    @Body() dto: CreateProducteurDto,
  ) {
    return this.producteurService.soumettre(req.user, dto);
  }

  @Patch('me')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Mettre a jour sa propre fiche producteur' })
  @ApiResponse({ status: 200, description: 'Fiche mise a jour' })
  @ApiResponse({ status: 404, description: 'Fiche introuvable' })
  mettreAJour(
    @Request() req: { user: Utilisateur },
    @Body() dto: UpdateProducteurDto,
  ) {
    return this.producteurService.mettreAJour(req.user.id_utilisateur, dto);
  }

  @Patch(':id/verification')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiOperation({ summary: 'Valider ou rejeter une fiche producteur (admin)' })
  @ApiResponse({ status: 200, description: 'Statut mis a jour' })
  @ApiResponse({ status: 403, description: 'Acces refuse' })
  @ApiResponse({ status: 404, description: 'Producteur introuvable' })
  verifier(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: VerifierProducteurDto,
    @Request() req: { user: Utilisateur },
  ) {
    return this.producteurService.verifier(id, dto, req.user);
  }
}
