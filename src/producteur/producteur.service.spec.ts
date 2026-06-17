import { Test, TestingModule } from '@nestjs/testing';
import {
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { ProducteurService } from './producteur.service';
import { PrismaService } from '../prisma/prisma.service';

// ----------------------------------------------------------------
// Fixtures
// ----------------------------------------------------------------

const mockUtilisateur = {
  id_utilisateur: 'user-1',
  email: 'jean@test.fr',
  role: 'user',
  statut_compte: 'actif',
};

const mockAdmin = {
  id_utilisateur: 'admin-1',
  email: 'admin@test.fr',
  role: 'admin',
  statut_compte: 'actif',
};

const mockProducteur = {
  id_producteur: 'prod-1',
  id_utilisateur: 'user-1',
  nom_exploitation: 'Ferme Dupont',
  raison_sociale: 'EARL Dupont',
  siret: '12345678901234',
  description: 'Maraichage bio',
  adresse_ligne1: '12 chemin des champs',
  ville: 'Lyon',
  region: 'Auvergne-Rhone-Alpes',
  departement: 'Rhone',
  coordonnees_lat: 45.748,
  coordonnees_lng: 4.847,
  telephone: '0612345678',
  email_contact: 'ferme@dupont.fr',
  horaires_ouverture: {},
  vente_directe: true,
  vente_paniers: false,
  livraison_possible: false,
  click_and_collect: false,
  commande_en_ligne: false,
  statut_verification: 'pending',
  visible_publiquement: true,
  date_creation: new Date(),
  date_modification: new Date(),
};

const mockCreerDto = {
  nom_exploitation: 'Ferme Dupont',
  raison_sociale: 'EARL Dupont',
  siret: '12345678901234',
  description: 'Maraichage bio',
  adresse_ligne1: '12 chemin des champs',
  ville: 'Lyon',
  region: 'Auvergne-Rhone-Alpes',
  departement: 'Rhone',
  coordonnees_lat: 45.748,
  coordonnees_lng: 4.847,
  telephone: '0612345678',
  email_contact: 'ferme@dupont.fr',
  horaires_ouverture: {},
  vente_directe: true,
  vente_paniers: false,
  livraison_possible: false,
};

const mockPrisma = {
  producteur: {
    findUnique: jest.fn(),
    findMany: jest.fn(),
    count: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
};

// ----------------------------------------------------------------
// Setup
// ----------------------------------------------------------------

describe('ProducteurService', () => {
  let service: ProducteurService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProducteurService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<ProducteurService>(ProducteurService);
    jest.clearAllMocks();
  });

  // ----------------------------------------------------------------
  // soumettre
  // ----------------------------------------------------------------

  describe('soumettre', () => {
    it('cree une fiche avec statut pending', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(null);
      mockPrisma.producteur.create.mockResolvedValue(mockProducteur);

      const result = await service.soumettre(mockUtilisateur as any, mockCreerDto as any);

      expect(mockPrisma.producteur.create).toHaveBeenCalledTimes(1);
      const createArg = mockPrisma.producteur.create.mock.calls[0][0];
      expect(createArg.data.statut_verification).toBe('pending');
      expect(result).toEqual(mockProducteur);
    });

    it('lie la fiche a l\'utilisateur connecte', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(null);
      mockPrisma.producteur.create.mockResolvedValue(mockProducteur);

      await service.soumettre(mockUtilisateur as any, mockCreerDto as any);

      const createArg = mockPrisma.producteur.create.mock.calls[0][0];
      expect(createArg.data.id_utilisateur).toBe('user-1');
    });

    it('leve ConflictException si l\'utilisateur a deja une fiche', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(mockProducteur);

      await expect(
        service.soumettre(mockUtilisateur as any, mockCreerDto as any),
      ).rejects.toThrow(ConflictException);

      expect(mockPrisma.producteur.create).not.toHaveBeenCalled();
    });
  });

  // ----------------------------------------------------------------
  // findPublics
  // ----------------------------------------------------------------

  describe('findPublics', () => {
    it('retourne uniquement les producteurs visible et verifies', async () => {
      mockPrisma.producteur.findMany.mockResolvedValue([mockProducteur]);
      mockPrisma.producteur.count.mockResolvedValue(1);

      await service.findPublics({ page: 1, limit: 10 });

      const whereArg = mockPrisma.producteur.findMany.mock.calls[0][0].where;
      expect(whereArg.visible_publiquement).toBe(true);
      expect(whereArg.statut_verification).toBe('verified');
    });

    it('retourne la liste et le total pour la pagination', async () => {
      mockPrisma.producteur.findMany.mockResolvedValue([mockProducteur]);
      mockPrisma.producteur.count.mockResolvedValue(1);

      const result = await service.findPublics({ page: 1, limit: 10 });

      expect(result).toEqual({ data: [mockProducteur], total: 1, page: 1, limit: 10 });
    });

    it('applique le bon offset selon la page', async () => {
      mockPrisma.producteur.findMany.mockResolvedValue([]);
      mockPrisma.producteur.count.mockResolvedValue(0);

      await service.findPublics({ page: 3, limit: 10 });

      const queryArg = mockPrisma.producteur.findMany.mock.calls[0][0];
      expect(queryArg.skip).toBe(20);
      expect(queryArg.take).toBe(10);
    });
  });

  // ----------------------------------------------------------------
  // findById
  // ----------------------------------------------------------------

  describe('findById', () => {
    it('retourne la fiche d\'un producteur public', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(mockProducteur);

      const result = await service.findById('prod-1');

      expect(result).toEqual(mockProducteur);
    });

    it('leve NotFoundException si le producteur est introuvable', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(null);

      await expect(service.findById('prod-inexistant')).rejects.toThrow(NotFoundException);
    });

    it('leve NotFoundException si le producteur n\'est pas visible publiquement', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue({
        ...mockProducteur,
        visible_publiquement: false,
      });

      await expect(service.findById('prod-1')).rejects.toThrow(NotFoundException);
    });
  });

  // ----------------------------------------------------------------
  // findMien
  // ----------------------------------------------------------------

  describe('findMien', () => {
    it('retourne la fiche de l\'utilisateur connecte', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(mockProducteur);

      const result = await service.findMien('user-1');

      expect(result).toEqual(mockProducteur);
      expect(mockPrisma.producteur.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({ where: { id_utilisateur: 'user-1' } }),
      );
    });

    it('leve NotFoundException si l\'utilisateur n\'a pas de fiche', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(null);

      await expect(service.findMien('user-sans-fiche')).rejects.toThrow(NotFoundException);
    });
  });

  // ----------------------------------------------------------------
  // mettreAJour
  // ----------------------------------------------------------------

  describe('mettreAJour', () => {
    it('met a jour la fiche du producteur', async () => {
      const updated = { ...mockProducteur, description: 'Nouvelle description' };
      mockPrisma.producteur.findUnique.mockResolvedValue(mockProducteur);
      mockPrisma.producteur.update.mockResolvedValue(updated);

      const result = await service.mettreAJour('user-1', { description: 'Nouvelle description' } as any);

      expect(result).toEqual(updated);
    });

    it('leve NotFoundException si l\'utilisateur n\'a pas de fiche', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(null);

      await expect(
        service.mettreAJour('user-sans-fiche', { description: 'x' } as any),
      ).rejects.toThrow(NotFoundException);

      expect(mockPrisma.producteur.update).not.toHaveBeenCalled();
    });
  });

  // ----------------------------------------------------------------
  // verifier (admin)
  // ----------------------------------------------------------------

  describe('verifier', () => {
    it('valide un producteur en attente', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(mockProducteur);
      mockPrisma.producteur.update.mockResolvedValue({
        ...mockProducteur,
        statut_verification: 'verified',
      });

      const result = await service.verifier(
        'prod-1',
        { statut_verification: 'verified' } as any,
        mockAdmin as any,
      );

      expect(result.statut_verification).toBe('verified');
      const updateArg = mockPrisma.producteur.update.mock.calls[0][0];
      expect(updateArg.data.id_admin_verificateur).toBe('admin-1');
      expect(updateArg.data.date_verification).toBeInstanceOf(Date);
    });

    it('rejette un producteur avec une note', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(mockProducteur);
      mockPrisma.producteur.update.mockResolvedValue({
        ...mockProducteur,
        statut_verification: 'rejected',
        note_admin: 'SIRET invalide',
      });

      await service.verifier(
        'prod-1',
        { statut_verification: 'rejected', note_admin: 'SIRET invalide' } as any,
        mockAdmin as any,
      );

      const updateArg = mockPrisma.producteur.update.mock.calls[0][0];
      expect(updateArg.data.note_admin).toBe('SIRET invalide');
    });

    it('leve NotFoundException si le producteur est introuvable', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(null);

      await expect(
        service.verifier('prod-inexistant', { statut_verification: 'verified' } as any, mockAdmin as any),
      ).rejects.toThrow(NotFoundException);
    });

    it('leve ForbiddenException si l\'appelant n\'est pas admin', async () => {
      mockPrisma.producteur.findUnique.mockResolvedValue(mockProducteur);

      await expect(
        service.verifier('prod-1', { statut_verification: 'verified' } as any, mockUtilisateur as any),
      ).rejects.toThrow(ForbiddenException);

      expect(mockPrisma.producteur.update).not.toHaveBeenCalled();
    });
  });
});
