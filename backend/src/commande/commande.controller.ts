import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Inject,
  Param,
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
import Stripe from 'stripe';
import { CommandeService } from './commande.service';
import { TarificationQueryDto } from './dto/tarification-query.dto';
import { CreerPaiementDto } from './dto/creer-paiement.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Utilisateur } from '../generated/prisma';
import { STRIPE_CLIENT } from './stripe.provider';

@ApiTags('commandes')
@Controller('commandes')
export class CommandeController {
  constructor(
    private readonly commandeService: CommandeService,
    @Inject(STRIPE_CLIENT) private readonly stripe: InstanceType<typeof Stripe>,
  ) {}

  @Get('tarification')
  @ApiOperation({
    summary: 'Calcul transparent des frais pour un prix producteur donné',
    description:
      'Retourne la décomposition prix producteur / commission Qarnea / frais Stripe / total client.',
  })
  @ApiResponse({ status: 200, description: 'Tarification calculée' })
  tarification(@Query() query: TarificationQueryDto) {
    return this.commandeService.calculerTarification(query.prix);
  }

  @Post('paiement')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Créer un PaymentIntent Stripe pour un article producteur' })
  @ApiResponse({ status: 201, description: 'client_secret et tarification retournés' })
  @ApiResponse({ status: 401, description: 'Non authentifié' })
  creerPaiement(
    @Body() dto: CreerPaiementDto,
    @Request() req: { user: Utilisateur },
  ) {
    return this.commandeService.creerPaiement(dto, req.user.id_utilisateur);
  }

  @Post('webhook')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Webhook Stripe (usage interne)',
    description:
      'Endpoint appelé par Stripe pour notifier les événements de paiement. Auth = signature Stripe.',
  })
  @ApiResponse({ status: 200, description: 'Event traité' })
  @ApiResponse({ status: 400, description: 'Signature invalide ou event inconnu' })
  async webhook(
    @Request() req: { rawBody?: Buffer },
    @Headers('stripe-signature') signature: string,
  ) {
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET ?? '';
    if (!webhookSecret) {
      throw new BadRequestException('STRIPE_WEBHOOK_SECRET non configuré');
    }

    let event: ReturnType<InstanceType<typeof Stripe>['webhooks']['constructEvent']>;
    try {
      event = this.stripe.webhooks.constructEvent(
        req.rawBody as Buffer,
        signature,
        webhookSecret,
      );
    } catch {
      throw new BadRequestException('Signature Stripe invalide');
    }

    if (event.type === 'payment_intent.succeeded') {
      const pi = event.data.object as { id: string };
      await this.commandeService.confirmerPaiement(pi.id);
    }

    return { received: true };
  }

  @Get('producteur/:id/ca-mensuel')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'CA mensuel courant du producteur (commandes payées)' })
  @ApiResponse({ status: 200, description: 'CA mensuel en euros (prix producteur)' })
  getCaMensuel(@Param('id') idProducteur: string) {
    return this.commandeService.getCaMensuel(idProducteur);
  }
}
