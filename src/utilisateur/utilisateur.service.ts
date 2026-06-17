import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfilDto } from './dto/update-profil.dto';
import { UpdateLocalisationDto } from './dto/update-localisation.dto';
import { Utilisateur } from '../generated/prisma';

const CHAMPS_PUBLICS = {
  id_utilisateur: true,
  email: true,
  nom: true,
  prenom: true,
  telephone: true,
  date_naissance: true,
  date_inscription: true,
  date_derniere_connexion: true,
  role: true,
  statut_compte: true,
  localisation_autorisee: true,
  localisation_lat: true,
  localisation_lng: true,
  ville_preferee: true,
  rayon_recherche_defaut: true,
  langue: true,
  accepte_notifications: true,
  avatar_url: true,
} as const;

@Injectable()
export class UtilisateurService {
  constructor(private readonly prisma: PrismaService) {}

  async getProfil(id: string) {
    const utilisateur = await this.prisma.utilisateur.findUnique({
      where: { id_utilisateur: id },
      select: CHAMPS_PUBLICS,
    });

    if (!utilisateur) {
      throw new NotFoundException('Utilisateur introuvable');
    }

    return utilisateur;
  }

  async updateProfil(id: string, dto: UpdateProfilDto) {
    const { date_naissance, ...rest } = dto;
    return this.prisma.utilisateur.update({
      where: { id_utilisateur: id },
      data: {
        ...rest,
        ...(date_naissance ? { date_naissance: new Date(date_naissance) } : {}),
      },
      select: CHAMPS_PUBLICS,
    });
  }

  async updateLocalisation(id: string, dto: UpdateLocalisationDto) {
    return this.prisma.utilisateur.update({
      where: { id_utilisateur: id },
      data: {
        localisation_lat: dto.localisation_lat,
        localisation_lng: dto.localisation_lng,
        localisation_autorisee: dto.localisation_autorisee ?? true,
      },
      select: CHAMPS_PUBLICS,
    });
  }

  async supprimerCompte(utilisateur: Utilisateur): Promise<void> {
    await this.prisma.utilisateur.delete({
      where: { id_utilisateur: utilisateur.id_utilisateur },
    });
  }
}
