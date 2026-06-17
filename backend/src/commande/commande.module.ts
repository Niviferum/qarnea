import { Module } from '@nestjs/common';
import { CommandeService } from './commande.service';
import { CommandeController } from './commande.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { stripeProvider } from './stripe.provider';

@Module({
  imports: [PrismaModule],
  controllers: [CommandeController],
  providers: [CommandeService, stripeProvider],
  exports: [CommandeService],
})
export class CommandeModule {}
