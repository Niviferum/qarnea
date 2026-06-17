import { Module } from '@nestjs/common';
import { AgenceBioController } from './agence-bio.controller';
import { AgenceBioService } from './agence-bio.service';
import { AgenceBioApiClient } from './clients/agence-bio-api.client';
import { AdresseApiClient } from './clients/adresse-api.client';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [AgenceBioController],
  providers: [AgenceBioService, AgenceBioApiClient, AdresseApiClient],
  exports: [AgenceBioService],
})
export class AgenceBioModule {}
