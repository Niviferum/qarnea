import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { ScanService } from './scan.service';
import { PrismaService } from '../prisma/prisma.service';
import { OpenFoodFactsApiClient } from './clients/openfoodfacts-api.client';

// ----------------------------------------------------------------
// Fixtures
// ----------------------------------------------------------------

const ID_UTILISATEUR = 'user-uuid-1';

const mockOffProductNutella = {
  product_name: 'Nutella',
  brands: 'Ferrero',
  categories: 'Confectionary based spreads, Petit-déjeuners, Produits à tartiner',
  categories_tags: ['en:breakfasts', 'en:spreads', 'en:sweet-spreads'],
  nutriscore_grade: 'e',
  nova_group: 4,
  ecoscore_grade: 'unknown',
  additives_n: 1,
  additives_tags: ['en:e322', 'en:e322i'],
  allergens_tags: ['en:milk', 'en:nuts', 'en:soybeans'],
  origins_tags: [],
  labels_tags: ['en:vegetarian', 'en:no-gluten'],
};

const mockOffProductBio = {
  product_name: 'Compote de pommes bio',
  brands: 'Bjorg',
  categories: 'Compotes, Aliments et boissons à base de végétaux',
  categories_tags: ['en:fruits', 'en:fruit-compotes', 'en:plant-based-foods'],
  nutriscore_grade: 'a',
  nova_group: 1,
  ecoscore_grade: 'a',
  additives_tags: [],
  allergens_tags: [],
  origins_tags: ['en:france'],
  labels_tags: ['en:organic', 'en:vegan'],
};

const mockProduitScanneCree = {
  id_produit_scanne: 'scan-uuid-1',
  id_utilisateur: ID_UTILISATEUR,
  code_barre: '3017620422003',
  nom_produit: 'Nutella',
  date_scan: new Date(),
};

const mockPrisma = {
  produitScanne: {
    create: jest.fn(),
    findMany: jest.fn(),
    count: jest.fn(),
    findFirst: jest.fn(),
  },
};

const mockOffApi = {
  fetchProduct: jest.fn(),
};

// ----------------------------------------------------------------
// Setup
// ----------------------------------------------------------------

describe('ScanService', () => {
  let service: ScanService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ScanService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: OpenFoodFactsApiClient, useValue: mockOffApi },
      ],
    }).compile();

    service = module.get<ScanService>(ScanService);
    jest.clearAllMocks();
  });

  // ----------------------------------------------------------------
  // scannerProduit
  // ----------------------------------------------------------------

  describe('scannerProduit', () => {
    it('leve NotFoundException si le produit est introuvable sur Open Food Facts', async () => {
      mockOffApi.fetchProduct.mockResolvedValue(null);

      await expect(
        service.scannerProduit(ID_UTILISATEUR, { code_barre: '0000000000000' }),
      ).rejects.toThrow(NotFoundException);

      expect(mockPrisma.produitScanne.create).not.toHaveBeenCalled();
    });

    it('enregistre le produit scanne avec les donnees mappees depuis OFF', async () => {
      mockOffApi.fetchProduct.mockResolvedValue(mockOffProductNutella);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      await service.scannerProduit(ID_UTILISATEUR, { code_barre: '3017620422003' });

      const createArg = mockPrisma.produitScanne.create.mock.calls[0][0].data;
      expect(createArg.id_utilisateur).toBe(ID_UTILISATEUR);
      expect(createArg.code_barre).toBe('3017620422003');
      expect(createArg.nom_produit).toBe('Nutella');
      expect(createArg.marque).toBe('Ferrero');
      expect(createArg.nutriscore).toBe('E');
      expect(createArg.score_nova).toBe(4);
      expect(createArg.nombre_additifs).toBe(1);
      expect(createArg.allergenes).toEqual(['en:milk', 'en:nuts', 'en:soybeans']);
      expect(createArg.source_donnees).toBe('open_food_facts');
      expect(createArg.donnees_off).toEqual(mockOffProductNutella);
    });

    it('met ecoscore a null quand OFF renvoie "unknown"', async () => {
      mockOffApi.fetchProduct.mockResolvedValue(mockOffProductNutella);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      await service.scannerProduit(ID_UTILISATEUR, { code_barre: '3017620422003' });

      const createArg = mockPrisma.produitScanne.create.mock.calls[0][0].data;
      expect(createArg.ecoscore).toBeNull();
    });

    it('detecte label_bio a partir du tag en:organic', async () => {
      mockOffApi.fetchProduct.mockResolvedValue(mockOffProductBio);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      await service.scannerProduit(ID_UTILISATEUR, { code_barre: '1111111111111' });

      const createArg = mockPrisma.produitScanne.create.mock.calls[0][0].data;
      expect(createArg.label_bio).toBe(true);
    });

    it('met label_bio a false si aucun tag bio n\'est present', async () => {
      mockOffApi.fetchProduct.mockResolvedValue(mockOffProductNutella);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      await service.scannerProduit(ID_UTILISATEUR, { code_barre: '3017620422003' });

      const createArg = mockPrisma.produitScanne.create.mock.calls[0][0].data;
      expect(createArg.label_bio).toBe(false);
    });

    it('enregistre la geolocalisation du scan si fournie', async () => {
      mockOffApi.fetchProduct.mockResolvedValue(mockOffProductNutella);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      await service.scannerProduit(ID_UTILISATEUR, {
        code_barre: '3017620422003',
        localisation_scan_lat: 48.117,
        localisation_scan_lng: -1.678,
      });

      const createArg = mockPrisma.produitScanne.create.mock.calls[0][0].data;
      expect(createArg.localisation_scan_lat).toBe(48.117);
      expect(createArg.localisation_scan_lng).toBe(-1.678);
    });

    it('retourne le produit scanne enrichi du flag origine_animale', async () => {
      mockOffApi.fetchProduct.mockResolvedValue(mockOffProductNutella);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      const result = await service.scannerProduit(ID_UTILISATEUR, {
        code_barre: '3017620422003',
      });

      expect(result).toMatchObject(mockProduitScanneCree);
      expect(result.origine_animale).toBe(false);
    });

    it('met ecoscore a null si OFF renvoie une valeur a plusieurs caracteres', async () => {
      const produit = { ...mockOffProductNutella, ecoscore_grade: 'a-plus' };
      mockOffApi.fetchProduct.mockResolvedValue(produit);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      await service.scannerProduit(ID_UTILISATEUR, { code_barre: '3017620422003' });

      const createArg = mockPrisma.produitScanne.create.mock.calls[0][0].data;
      expect(createArg.ecoscore).toBeNull();
    });

    it('retombe sur la longueur de additives_tags si additives_n est absent', async () => {
      const produit = { ...mockOffProductNutella, additives_n: undefined };
      mockOffApi.fetchProduct.mockResolvedValue(produit);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      await service.scannerProduit(ID_UTILISATEUR, { code_barre: '3017620422003' });

      const createArg = mockPrisma.produitScanne.create.mock.calls[0][0].data;
      expect(createArg.nombre_additifs).toBe(2);
    });

    it('marque origine_animale a true pour une categorie animale', async () => {
      const produitViande = { ...mockOffProductNutella, categories_tags: ['en:meats'] };
      mockOffApi.fetchProduct.mockResolvedValue(produitViande);
      mockPrisma.produitScanne.create.mockResolvedValue(mockProduitScanneCree);

      const result = await service.scannerProduit(ID_UTILISATEUR, {
        code_barre: '3017620422003',
      });

      expect(result.origine_animale).toBe(true);
    });
  });

  // ----------------------------------------------------------------
  // getHistorique
  // ----------------------------------------------------------------

  describe('getHistorique', () => {
    it('retourne les scans de l\'utilisateur, du plus recent au plus ancien', async () => {
      mockPrisma.produitScanne.findMany.mockResolvedValue([mockProduitScanneCree]);
      mockPrisma.produitScanne.count.mockResolvedValue(1);

      const result = await service.getHistorique(ID_UTILISATEUR, { page: 1, limit: 20 });

      expect(result).toEqual({ data: [mockProduitScanneCree], total: 1, page: 1, limit: 20 });
      const queryArg = mockPrisma.produitScanne.findMany.mock.calls[0][0];
      expect(queryArg.where.id_utilisateur).toBe(ID_UTILISATEUR);
      expect(queryArg.orderBy).toEqual({ date_scan: 'desc' });
    });

    it('applique le bon offset selon la page', async () => {
      mockPrisma.produitScanne.findMany.mockResolvedValue([]);
      mockPrisma.produitScanne.count.mockResolvedValue(0);

      await service.getHistorique(ID_UTILISATEUR, { page: 2, limit: 10 });

      const queryArg = mockPrisma.produitScanne.findMany.mock.calls[0][0];
      expect(queryArg.skip).toBe(10);
      expect(queryArg.take).toBe(10);
    });
  });

  // ----------------------------------------------------------------
  // getScanParId
  // ----------------------------------------------------------------

  describe('getScanParId', () => {
    it('retourne le scan si trouve et appartenant a l\'utilisateur', async () => {
      mockPrisma.produitScanne.findFirst.mockResolvedValue(mockProduitScanneCree);

      const result = await service.getScanParId(ID_UTILISATEUR, 'scan-uuid-1');

      expect(result).toEqual(mockProduitScanneCree);
      expect(mockPrisma.produitScanne.findFirst).toHaveBeenCalledWith({
        where: { id_produit_scanne: 'scan-uuid-1', id_utilisateur: ID_UTILISATEUR },
      });
    });

    it('leve NotFoundException si le scan n\'existe pas ou n\'appartient pas a l\'utilisateur', async () => {
      mockPrisma.produitScanne.findFirst.mockResolvedValue(null);

      await expect(service.getScanParId(ID_UTILISATEUR, 'inconnu')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
