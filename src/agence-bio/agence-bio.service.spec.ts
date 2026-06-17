import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { AgenceBioService } from './agence-bio.service';
import { PrismaService } from '../prisma/prisma.service';
import { AgenceBioApiClient } from './clients/agence-bio-api.client';
import { AdresseApiClient } from './clients/adresse-api.client';

// ----------------------------------------------------------------
// Fixtures
// ----------------------------------------------------------------

const mockOperateurCache = {
  numero_bio: '12345',
  raison_sociale: 'EARL Dupont Bio',
  siret: '12345678901234',
  adresse: '15 chemin des vignes',
  code_postal: '35000',
  ville: 'Rennes',
  departement: 'Ille-et-Vilaine',
  coordonnees_lat: null,
  coordonnees_lng: null,
  geocodage_effectue: false,
  produits_certifies: null,
  activites: null,
  organisme_certificateur: 'Ecocert',
  date_mise_a_jour: new Date(),
};

const mockOperateurGeocoded = {
  ...mockOperateurCache,
  coordonnees_lat: 48.117,
  coordonnees_lng: -1.678,
  geocodage_effectue: true,
};

const mockOperateurApi = {
  numeroBio: '12345',
  raisonSociale: 'EARL Dupont Bio',
  siret: '12345678901234',
  adressesPrincipales: [
    {
      lieu: '15 chemin des vignes',
      codePostal: '35000',
      ville: 'Rennes',
      departementLabel: 'Ille-et-Vilaine',
    },
  ],
  produits: [{ code: '01', nom: 'Légumes' }],
  activites: [{ id: 1, nom: 'Producteur' }],
  organismeCertificateur: { nom: 'Ecocert' },
};

const mockPrisma = {
  agenceBioOperateur: {
    findUnique: jest.fn(),
    findMany: jest.fn(),
    count: jest.fn(),
    upsert: jest.fn(),
    update: jest.fn(),
  },
};

const mockAgenceBioApi = {
  fetchPage: jest.fn(),
};

const mockAdresseApi = {
  geocoder: jest.fn(),
};

// ----------------------------------------------------------------
// Setup
// ----------------------------------------------------------------

describe('AgenceBioService', () => {
  let service: AgenceBioService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AgenceBioService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: AgenceBioApiClient, useValue: mockAgenceBioApi },
        { provide: AdresseApiClient, useValue: mockAdresseApi },
      ],
    }).compile();

    service = module.get<AgenceBioService>(AgenceBioService);
    jest.clearAllMocks();
  });

  // ----------------------------------------------------------------
  // rechercherOperateurs
  // ----------------------------------------------------------------

  describe('rechercherOperateurs', () => {
    it('retourne une liste paginee depuis le cache', async () => {
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([mockOperateurCache]);
      mockPrisma.agenceBioOperateur.count.mockResolvedValue(1);

      const result = await service.rechercherOperateurs({ page: 1, limit: 20 });

      expect(result).toEqual({ data: [mockOperateurCache], total: 1, page: 1, limit: 20 });
    });

    it('filtre par departement si specifie', async () => {
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([]);
      mockPrisma.agenceBioOperateur.count.mockResolvedValue(0);

      await service.rechercherOperateurs({ page: 1, limit: 20, departement: 'Ille-et-Vilaine' });

      const whereArg = mockPrisma.agenceBioOperateur.findMany.mock.calls[0][0].where;
      expect(whereArg.departement).toBe('Ille-et-Vilaine');
    });

    it('filtre par recherche textuelle sur raison_sociale et ville', async () => {
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([]);
      mockPrisma.agenceBioOperateur.count.mockResolvedValue(0);

      await service.rechercherOperateurs({ page: 1, limit: 20, q: 'dupont' });

      const whereArg = mockPrisma.agenceBioOperateur.findMany.mock.calls[0][0].where;
      expect(whereArg.OR).toBeDefined();
    });

    it('applique le bon offset selon la page', async () => {
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([]);
      mockPrisma.agenceBioOperateur.count.mockResolvedValue(0);

      await service.rechercherOperateurs({ page: 3, limit: 10 });

      const queryArg = mockPrisma.agenceBioOperateur.findMany.mock.calls[0][0];
      expect(queryArg.skip).toBe(20);
      expect(queryArg.take).toBe(10);
    });
  });

  // ----------------------------------------------------------------
  // findByNumeroBio
  // ----------------------------------------------------------------

  describe('findByNumeroBio', () => {
    it('retourne l\'operateur si present dans le cache', async () => {
      mockPrisma.agenceBioOperateur.findUnique.mockResolvedValue(mockOperateurCache);

      const result = await service.findByNumeroBio('12345');

      expect(result).toEqual(mockOperateurCache);
      expect(mockPrisma.agenceBioOperateur.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({ where: { numero_bio: '12345' } }),
      );
    });

    it('leve NotFoundException si le numero_bio est inconnu', async () => {
      mockPrisma.agenceBioOperateur.findUnique.mockResolvedValue(null);

      await expect(service.findByNumeroBio('99999')).rejects.toThrow(NotFoundException);
    });
  });

  // ----------------------------------------------------------------
  // syncDepartement
  // ----------------------------------------------------------------

  describe('syncDepartement', () => {
    it('upsert les operateurs de la premiere page', async () => {
      mockAgenceBioApi.fetchPage.mockResolvedValue({
        items: [mockOperateurApi],
        pagination: { page: 0, pageSize: 100, totalCount: 1 },
      });
      mockPrisma.agenceBioOperateur.upsert.mockResolvedValue(mockOperateurCache);

      await service.syncDepartement('35');

      expect(mockPrisma.agenceBioOperateur.upsert).toHaveBeenCalledTimes(1);
      const upsertArg = mockPrisma.agenceBioOperateur.upsert.mock.calls[0][0];
      expect(upsertArg.where.numero_bio).toBe('12345');
      expect(upsertArg.create.raison_sociale).toBe('EARL Dupont Bio');
    });

    it('mappe correctement l\'adresse principale', async () => {
      mockAgenceBioApi.fetchPage.mockResolvedValue({
        items: [mockOperateurApi],
        pagination: { page: 0, pageSize: 100, totalCount: 1 },
      });
      mockPrisma.agenceBioOperateur.upsert.mockResolvedValue(mockOperateurCache);

      await service.syncDepartement('35');

      const upsertArg = mockPrisma.agenceBioOperateur.upsert.mock.calls[0][0];
      expect(upsertArg.create.adresse).toBe('15 chemin des vignes');
      expect(upsertArg.create.code_postal).toBe('35000');
      expect(upsertArg.create.ville).toBe('Rennes');
    });

    it('fetche toutes les pages quand totalCount depasse pageSize', async () => {
      mockAgenceBioApi.fetchPage
        .mockResolvedValueOnce({
          items: [mockOperateurApi],
          pagination: { page: 0, pageSize: 1, totalCount: 2 },
        })
        .mockResolvedValueOnce({
          items: [{ ...mockOperateurApi, numeroBio: '99999' }],
          pagination: { page: 1, pageSize: 1, totalCount: 2 },
        });
      mockPrisma.agenceBioOperateur.upsert.mockResolvedValue(mockOperateurCache);

      await service.syncDepartement('35');

      expect(mockAgenceBioApi.fetchPage).toHaveBeenCalledTimes(2);
      expect(mockPrisma.agenceBioOperateur.upsert).toHaveBeenCalledTimes(2);
    });

    it('retourne le nombre d\'operateurs synchronises', async () => {
      mockAgenceBioApi.fetchPage.mockResolvedValue({
        items: [mockOperateurApi, { ...mockOperateurApi, numeroBio: '99999' }],
        pagination: { page: 0, pageSize: 100, totalCount: 2 },
      });
      mockPrisma.agenceBioOperateur.upsert.mockResolvedValue(mockOperateurCache);

      const result = await service.syncDepartement('35');

      expect(result).toBe(2);
    });
  });

  // ----------------------------------------------------------------
  // geocoderNonGeocodes
  // ----------------------------------------------------------------

  describe('geocoderNonGeocodes', () => {
    it('geocode les operateurs sans coordonnees et met a jour le cache', async () => {
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([mockOperateurCache]);
      mockAdresseApi.geocoder.mockResolvedValue({ lat: 48.117, lng: -1.678, score: 0.9 });
      mockPrisma.agenceBioOperateur.update.mockResolvedValue(mockOperateurGeocoded);

      await service.geocoderNonGeocodes(10);

      expect(mockAdresseApi.geocoder).toHaveBeenCalledTimes(1);
      const updateArg = mockPrisma.agenceBioOperateur.update.mock.calls[0][0];
      expect(updateArg.where.numero_bio).toBe('12345');
      expect(updateArg.data.coordonnees_lat).toBe(48.117);
      expect(updateArg.data.coordonnees_lng).toBe(-1.678);
      expect(updateArg.data.geocodage_effectue).toBe(true);
    });

    it('ne geocode pas les operateurs deja geocodes', async () => {
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([]);

      await service.geocoderNonGeocodes(10);

      expect(mockAdresseApi.geocoder).not.toHaveBeenCalled();
    });

    it('ignore les operateurs sans adresse ni code_postal', async () => {
      const sansAdresse = { ...mockOperateurCache, adresse: null, code_postal: null };
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([sansAdresse]);

      await service.geocoderNonGeocodes(10);

      expect(mockAdresseApi.geocoder).not.toHaveBeenCalled();
      expect(mockPrisma.agenceBioOperateur.update).not.toHaveBeenCalled();
    });

    it('ignore les operateurs quand le geocodage ne retourne rien', async () => {
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([mockOperateurCache]);
      mockAdresseApi.geocoder.mockResolvedValue(null);

      await service.geocoderNonGeocodes(10);

      expect(mockPrisma.agenceBioOperateur.update).not.toHaveBeenCalled();
    });

    it('retourne le nombre d\'operateurs geocodes avec succes', async () => {
      const deux = [mockOperateurCache, { ...mockOperateurCache, numero_bio: '99999' }];
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue(deux);
      mockAdresseApi.geocoder.mockResolvedValue({ lat: 48.117, lng: -1.678, score: 0.9 });
      mockPrisma.agenceBioOperateur.update.mockResolvedValue(mockOperateurGeocoded);

      const result = await service.geocoderNonGeocodes(10);

      expect(result).toBe(2);
    });

    it('respecte la limite passee en parametre', async () => {
      mockPrisma.agenceBioOperateur.findMany.mockResolvedValue([]);

      await service.geocoderNonGeocodes(5);

      const queryArg = mockPrisma.agenceBioOperateur.findMany.mock.calls[0][0];
      expect(queryArg.take).toBe(5);
      expect(queryArg.where.geocodage_effectue).toBe(false);
    });
  });
});
