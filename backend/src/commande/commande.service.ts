import {
  BadRequestException,
  Inject,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import Stripe from 'stripe';
import { PrismaService } from '../prisma/prisma.service';
import { CreerPaiementDto } from './dto/creer-paiement.dto';
import { StatutCommande } from '../generated/prisma';
import { STRIPE_CLIENT } from './stripe.provider';

const COMMISSION_RATE = 0.04;
const STRIPE_RATE = 0.015;
const STRIPE_FIXED_CENTS = 25;

export interface Tarification {
  prix_producteur: number;
  commission_qarnea: number;
  frais_stripe: number;
  total: number;
  note_carte_hors_ue: string;
}

@Injectable()
export class CommandeService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(STRIPE_CLIENT) private readonly stripe: InstanceType<typeof Stripe>,
  ) {}

  calculerTarification(prixProducteurEuros: number): Tarification {
    const prixCents = Math.round(prixProducteurEuros * 100);
    const commissionCents = Math.round(prixCents * COMMISSION_RATE);

    // T = (P + commission + stripe_fixe) / (1 - stripe_rate)
    const totalCents = Math.ceil(
      (prixCents + commissionCents + STRIPE_FIXED_CENTS) / (1 - STRIPE_RATE),
    );

    const fraisStripeCents =
      Math.round(totalCents * STRIPE_RATE) + STRIPE_FIXED_CENTS;

    return {
      prix_producteur: prixCents / 100,
      commission_qarnea: commissionCents / 100,
      frais_stripe: fraisStripeCents / 100,
      total: totalCents / 100,
      note_carte_hors_ue:
        "Calculé pour une carte UE (1,5 % + 0,25 €). Un surcoût peut s'appliquer avec une carte hors UE.",
    };
  }

  async creerPaiement(
    dto: CreerPaiementDto,
    idUtilisateur: string,
  ): Promise<{ client_secret: string; tarification: Tarification }> {
    const tarification = this.calculerTarification(dto.prix_producteur);
    const totalCents = Math.round(tarification.total * 100);

    let piId: string;
    let clientSecret: string;
    try {
      const pi = await this.stripe.paymentIntents.create({
        amount: totalCents,
        currency: 'eur',
        description: dto.description,
        metadata: {
          id_utilisateur: idUtilisateur,
          id_producteur: dto.id_producteur,
          prix_producteur: tarification.prix_producteur.toFixed(2),
          commission_qarnea: tarification.commission_qarnea.toFixed(2),
          frais_stripe: tarification.frais_stripe.toFixed(2),
        },
      });
      piId = pi.id;
      clientSecret = pi.client_secret ?? '';
    } catch {
      throw new InternalServerErrorException(
        'Erreur lors de la création du paiement Stripe',
      );
    }

    if (!clientSecret) {
      throw new InternalServerErrorException(
        "Stripe n'a pas retourné de client_secret",
      );
    }

    await this.prisma.commande.create({
      data: {
        stripe_payment_intent_id: piId,
        id_utilisateur: idUtilisateur,
        id_producteur: dto.id_producteur,
        description: dto.description,
        prix_producteur: tarification.prix_producteur,
        commission_qarnea: tarification.commission_qarnea,
        frais_stripe: tarification.frais_stripe,
        total: tarification.total,
        statut: StatutCommande.en_attente,
      },
    });

    return { client_secret: clientSecret, tarification };
  }

  async confirmerPaiement(stripePaymentIntentId: string): Promise<void> {
    const commande = await this.prisma.commande.findUnique({
      where: { stripe_payment_intent_id: stripePaymentIntentId },
    });

    if (!commande) {
      throw new BadRequestException(
        `Commande inconnue pour le PaymentIntent ${stripePaymentIntentId}`,
      );
    }

    // Idempotence : Stripe peut redélivrer l'event
    if (commande.statut === StatutCommande.payee) {
      return;
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.commande.update({
        where: { stripe_payment_intent_id: stripePaymentIntentId },
        data: {
          statut: StatutCommande.payee,
          date_paiement: new Date(),
        },
      });

      await tx.notification.create({
        data: {
          id_utilisateur: commande.id_utilisateur,
          type: 'paiement_confirme',
          titre: 'Paiement confirmé',
          message: `Votre paiement pour "${commande.description}" a bien été reçu.`,
          lue: false,
          date_envoi: new Date(),
        },
      });
    });
  }

  async getCaMensuel(
    idProducteur: string,
  ): Promise<{ ca_mensuel: number; mois: string }> {
    const maintenant = new Date();
    const debutMois = new Date(
      maintenant.getFullYear(),
      maintenant.getMonth(),
      1,
    );
    const debutMoisSuivant = new Date(
      maintenant.getFullYear(),
      maintenant.getMonth() + 1,
      1,
    );

    const agregat = await this.prisma.commande.aggregate({
      where: {
        id_producteur: idProducteur,
        statut: StatutCommande.payee,
        date_paiement: { gte: debutMois, lt: debutMoisSuivant },
      },
      _sum: { prix_producteur: true },
    });

    const mois = `${maintenant.getFullYear()}-${String(maintenant.getMonth() + 1).padStart(2, '0')}`;

    return {
      ca_mensuel: Number(agregat._sum.prix_producteur ?? 0),
      mois,
    };
  }
}
