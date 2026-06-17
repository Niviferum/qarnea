import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { UtilisateurService } from './utilisateur.service';
import { PrismaService } from '../prisma/prisma.service';

const mockUtilisateur = {
  id_utilisateur: 'uuid-1',
  email: 'jean@test.fr',
  nom: 'Dupont',
  prenom: 'Jean',
  telephone: null,
  date_naissance: null,
  date_inscription: new Date(),
  date_derniere_connexion: null,
  role: 'user',
  statut_compte: 'actif',
  localisation_autorisee: true,
  localisation_lat: null,
  localisation_lng: null,
  ville_preferee: null,
  rayon_recherche_defaut: 20,
  langue: 'fr',
  accepte_notifications: true,
  avatar_url: null,
};

const mockPrisma = {
  utilisateur: {
    findUnique: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
};

describe('UtilisateurService', () => {
  let service: UtilisateurService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UtilisateurService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<UtilisateurService>(UtilisateurService);
    jest.clearAllMocks();
  });

  // ----------------------------------------------------------------
  // getProfil
  // ----------------------------------------------------------------

  describe('getProfil', () => {
    it('retourne le profil de l\'utilisateur', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(mockUtilisateur);

      const result = await service.getProfil('uuid-1');

      expect(result).toEqual(mockUtilisateur);
      expect(mockPrisma.utilisateur.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({ where: { id_utilisateur: 'uuid-1' } }),
      );
    });

    it('leve NotFoundException si l\'utilisateur est introuvable', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(null);

      await expect(service.getProfil('uuid-inexistant')).rejects.toThrow(NotFoundException);
    });

    it('ne retourne pas le password_hash dans le profil', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(mockUtilisateur);

      const result = await service.getProfil('uuid-1') as Record<string, unknown>;

      expect(result).not.toHaveProperty('password_hash');
    });

    it('ne retourne pas le stripe_customer_id dans le profil', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(mockUtilisateur);

      const result = await service.getProfil('uuid-1') as Record<string, unknown>;

      expect(result).not.toHaveProperty('stripe_customer_id');
    });
  });

  // ----------------------------------------------------------------
  // updateProfil
  // ----------------------------------------------------------------

  describe('updateProfil', () => {
    it('met a jour les champs transmis', async () => {
      const updated = { ...mockUtilisateur, nom: 'Martin' };
      mockPrisma.utilisateur.update.mockResolvedValue(updated);

      const result = await service.updateProfil('uuid-1', { nom: 'Martin' });

      expect(result).toEqual(updated);
      expect(mockPrisma.utilisateur.update).toHaveBeenCalledWith(
        expect.objectContaining({ where: { id_utilisateur: 'uuid-1' } }),
      );
    });

    it('convertit date_naissance en objet Date avant l\'envoi a Prisma', async () => {
      mockPrisma.utilisateur.update.mockResolvedValue(mockUtilisateur);

      await service.updateProfil('uuid-1', { date_naissance: '1990-05-15' });

      const dataArg = mockPrisma.utilisateur.update.mock.calls[0][0].data;
      expect(dataArg.date_naissance).toBeInstanceOf(Date);
      expect(dataArg.date_naissance.getFullYear()).toBe(1990);
    });

    it('n\'inclut pas date_naissance si elle n\'est pas fournie', async () => {
      mockPrisma.utilisateur.update.mockResolvedValue(mockUtilisateur);

      await service.updateProfil('uuid-1', { nom: 'Martin' });

      const dataArg = mockPrisma.utilisateur.update.mock.calls[0][0].data;
      expect(dataArg).not.toHaveProperty('date_naissance');
    });
  });

  // ----------------------------------------------------------------
  // updateLocalisation
  // ----------------------------------------------------------------

  describe('updateLocalisation', () => {
    it('met a jour les coordonnees GPS', async () => {
      const updated = { ...mockUtilisateur, localisation_lat: 45.748, localisation_lng: 4.847 };
      mockPrisma.utilisateur.update.mockResolvedValue(updated);

      const result = await service.updateLocalisation('uuid-1', {
        localisation_lat: 45.748,
        localisation_lng: 4.847,
      });

      expect(result).toEqual(updated);
      const dataArg = mockPrisma.utilisateur.update.mock.calls[0][0].data;
      expect(dataArg.localisation_lat).toBe(45.748);
      expect(dataArg.localisation_lng).toBe(4.847);
    });

    it('met localisation_autorisee a true par defaut si non fourni', async () => {
      mockPrisma.utilisateur.update.mockResolvedValue(mockUtilisateur);

      await service.updateLocalisation('uuid-1', {
        localisation_lat: 45.748,
        localisation_lng: 4.847,
      });

      const dataArg = mockPrisma.utilisateur.update.mock.calls[0][0].data;
      expect(dataArg.localisation_autorisee).toBe(true);
    });

    it('respecte localisation_autorisee si fourni explicitement', async () => {
      mockPrisma.utilisateur.update.mockResolvedValue(mockUtilisateur);

      await service.updateLocalisation('uuid-1', {
        localisation_lat: 45.748,
        localisation_lng: 4.847,
        localisation_autorisee: false,
      });

      const dataArg = mockPrisma.utilisateur.update.mock.calls[0][0].data;
      expect(dataArg.localisation_autorisee).toBe(false);
    });
  });

  // ----------------------------------------------------------------
  // supprimerCompte
  // ----------------------------------------------------------------

  describe('supprimerCompte', () => {
    it('supprime le compte de l\'utilisateur', async () => {
      mockPrisma.utilisateur.delete.mockResolvedValue(mockUtilisateur);

      await service.supprimerCompte(mockUtilisateur as any);

      expect(mockPrisma.utilisateur.delete).toHaveBeenCalledWith({
        where: { id_utilisateur: 'uuid-1' },
      });
    });

    it('ne retourne rien apres la suppression', async () => {
      mockPrisma.utilisateur.delete.mockResolvedValue(mockUtilisateur);

      const result = await service.supprimerCompte(mockUtilisateur as any);

      expect(result).toBeUndefined();
    });
  });
});
