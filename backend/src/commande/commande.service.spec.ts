import { Test, TestingModule } from '@nestjs/testing';
import { InternalServerErrorException, BadRequestException } from '@nestjs/common';
import { CommandeService } from './commande.service';
import { PrismaService } from '../prisma/prisma.service';
import { STRIPE_CLIENT } from './stripe.provider';
import Stripe from 'stripe';

// ----------------------------------------------------------------
// Fixtures
// ----------------------------------------------------------------

const ID_UTILISATEUR = 'user-uuid-1';
const ID_PRODUCTEUR = 'producteur-uuid-1';
const PAYMENT_INTENT_ID = 'pi_test_abc123';
const ID_COMMANDE = 'commande-uuid-1';

const mockCommandeEnAttente = {
  id_commande: ID_COMMANDE,
  stripe_payment_intent_id: PAYMENT_INTENT_ID,
  id_utilisateur: ID_UTILISATEUR,
  id_producteur: ID_PRODUCTEUR,
  description: 'Steak fermier 200g',
  prix_producteur: 4.0,
  commission_qarnea: 0.16,
  frais_stripe: 0.32,
  total: 4.48,
  statut: 'en_attente',
  date_creation: new Date(),
  date_paiement: null,
};

const mockCommandePayee = {
  ...mockCommandeEnAttente,
  statut: 'payee',
  date_paiement: new Date(),
};

const mockPrisma = {
  commande: {
    create: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    aggregate: jest.fn(),
  },
  notification: {
    create: jest.fn(),
  },
  $transaction: jest.fn(),
};

const mockStripe = {
  paymentIntents: {
    create: jest.fn(),
  },
};

jest.mock('stripe', () => {
  return jest.fn().mockImplementation(() => mockStripe);
});

// ----------------------------------------------------------------
// Tests
// ----------------------------------------------------------------

describe('CommandeService', () => {
  let service: CommandeService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommandeService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: STRIPE_CLIENT, useValue: mockStripe },
      ],
    }).compile();

    service = module.get<CommandeService>(CommandeService);
    jest.clearAllMocks();
  });

  // ---- calculerTarification ----------------------------------------

  describe('calculerTarification', () => {
    it('décompose correctement un prix de 4 €', () => {
      const result = service.calculerTarification(4.0);

      expect(result.prix_producteur).toBe(4.0);
      expect(result.commission_qarnea).toBe(0.16); // 4 % de 4 €
      // Total = ceil((400 + 16 + 25) / (1 - 0.015)) = ceil(441 / 0.985) = ceil(447.7…) = 448 cents
      expect(result.total).toBe(4.48);
      expect(result.frais_stripe).toBeGreaterThan(0);
      expect(result.total).toBeGreaterThan(result.prix_producteur + result.commission_qarnea);
    });

    it('retourne les frais stripe dans la note (carte hors UE)', () => {
      const result = service.calculerTarification(10.0);
      expect(result.note_carte_hors_ue).toContain('1,5');
    });
  });

  // ---- creerPaiement -----------------------------------------------

  describe('creerPaiement', () => {
    const dto = {
      prix_producteur: 4.0,
      description: 'Steak fermier 200g',
      id_producteur: ID_PRODUCTEUR,
    };

    it('crée un PaymentIntent Stripe et persiste une Commande en_attente', async () => {
      mockStripe.paymentIntents.create.mockResolvedValue({
        id: PAYMENT_INTENT_ID,
        client_secret: 'cs_test_secret',
      });
      mockPrisma.commande.create.mockResolvedValue(mockCommandeEnAttente);

      const result = await service.creerPaiement(dto, ID_UTILISATEUR);

      expect(mockStripe.paymentIntents.create).toHaveBeenCalledWith(
        expect.objectContaining({
          currency: 'eur',
          metadata: expect.objectContaining({
            id_utilisateur: ID_UTILISATEUR,
            id_producteur: ID_PRODUCTEUR,
          }),
        }),
      );
      expect(mockPrisma.commande.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            stripe_payment_intent_id: PAYMENT_INTENT_ID,
            id_utilisateur: ID_UTILISATEUR,
            id_producteur: ID_PRODUCTEUR,
            statut: 'en_attente',
          }),
        }),
      );
      expect(result.client_secret).toBe('cs_test_secret');
      expect(result.tarification.total).toBeGreaterThan(0);
    });

    it('lève InternalServerErrorException si Stripe échoue', async () => {
      mockStripe.paymentIntents.create.mockRejectedValue(new Error('Stripe error'));

      await expect(service.creerPaiement(dto, ID_UTILISATEUR)).rejects.toThrow(
        InternalServerErrorException,
      );
      expect(mockPrisma.commande.create).not.toHaveBeenCalled();
    });

    it('lève InternalServerErrorException si Stripe ne renvoie pas de client_secret', async () => {
      mockStripe.paymentIntents.create.mockResolvedValue({
        id: PAYMENT_INTENT_ID,
        client_secret: null,
      });

      await expect(service.creerPaiement(dto, ID_UTILISATEUR)).rejects.toThrow(
        InternalServerErrorException,
      );
    });
  });

  // ---- confirmerPaiement -------------------------------------------

  describe('confirmerPaiement', () => {
    it('passe la commande à payee et crée une notification', async () => {
      mockPrisma.commande.findUnique.mockResolvedValue(mockCommandeEnAttente);
      mockPrisma.$transaction.mockImplementation(async (fn: (tx: typeof mockPrisma) => Promise<unknown>) => fn(mockPrisma));
      mockPrisma.commande.update.mockResolvedValue(mockCommandePayee);
      mockPrisma.notification.create.mockResolvedValue({ id_notification: 'notif-1' });

      await service.confirmerPaiement(PAYMENT_INTENT_ID);

      expect(mockPrisma.commande.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { stripe_payment_intent_id: PAYMENT_INTENT_ID },
          data: expect.objectContaining({
            statut: 'payee',
            date_paiement: expect.any(Date),
          }),
        }),
      );
      expect(mockPrisma.notification.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            id_utilisateur: ID_UTILISATEUR,
            type: 'paiement_confirme',
          }),
        }),
      );
    });

    it('est idempotent : ne fait rien si la commande est déjà payee', async () => {
      mockPrisma.commande.findUnique.mockResolvedValue(mockCommandePayee);

      await service.confirmerPaiement(PAYMENT_INTENT_ID);

      expect(mockPrisma.commande.update).not.toHaveBeenCalled();
      expect(mockPrisma.notification.create).not.toHaveBeenCalled();
    });

    it('lève BadRequestException si le payment_intent_id est inconnu', async () => {
      mockPrisma.commande.findUnique.mockResolvedValue(null);

      await expect(service.confirmerPaiement('pi_inconnu')).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  // ---- getCaMensuel ------------------------------------------------

  describe('getCaMensuel', () => {
    it('retourne la somme des prix_producteur payés sur le mois courant', async () => {
      mockPrisma.commande.aggregate.mockResolvedValue({
        _sum: { prix_producteur: 120.5 },
      });

      const result = await service.getCaMensuel(ID_PRODUCTEUR);

      expect(mockPrisma.commande.aggregate).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            id_producteur: ID_PRODUCTEUR,
            statut: 'payee',
          }),
          _sum: { prix_producteur: true },
        }),
      );
      expect(result.ca_mensuel).toBe(120.5);
      expect(result.mois).toMatch(/^\d{4}-\d{2}$/); // format YYYY-MM
    });

    it('retourne 0 si aucune commande payée ce mois', async () => {
      mockPrisma.commande.aggregate.mockResolvedValue({
        _sum: { prix_producteur: null },
      });

      const result = await service.getCaMensuel(ID_PRODUCTEUR);

      expect(result.ca_mensuel).toBe(0);
    });
  });
});
