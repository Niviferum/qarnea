import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Request,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { UtilisateurService } from './utilisateur.service';
import { UpdateProfilDto } from './dto/update-profil.dto';
import { UpdateLocalisationDto } from './dto/update-localisation.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Utilisateur } from '../generated/prisma';

@ApiTags('utilisateurs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('utilisateurs')
export class UtilisateurController {
  constructor(private readonly utilisateurService: UtilisateurService) {}

  @Get('me')
  @ApiOperation({ summary: 'Profil de l\'utilisateur connecte' })
  @ApiResponse({ status: 200, description: 'Profil retourne' })
  getProfil(@Request() req: { user: Utilisateur }) {
    return this.utilisateurService.getProfil(req.user.id_utilisateur);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Mise a jour du profil' })
  @ApiResponse({ status: 200, description: 'Profil mis a jour' })
  updateProfil(
    @Request() req: { user: Utilisateur },
    @Body() dto: UpdateProfilDto,
  ) {
    return this.utilisateurService.updateProfil(req.user.id_utilisateur, dto);
  }

  @Patch('me/localisation')
  @ApiOperation({ summary: 'Mise a jour des coordonnees GPS' })
  @ApiResponse({ status: 200, description: 'Localisation mise a jour' })
  updateLocalisation(
    @Request() req: { user: Utilisateur },
    @Body() dto: UpdateLocalisationDto,
  ) {
    return this.utilisateurService.updateLocalisation(req.user.id_utilisateur, dto);
  }

  @Delete('me')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Suppression du compte' })
  @ApiResponse({ status: 204, description: 'Compte supprime' })
  supprimerCompte(@Request() req: { user: Utilisateur }) {
    return this.utilisateurService.supprimerCompte(req.user);
  }
}
