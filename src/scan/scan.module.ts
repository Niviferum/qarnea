import { Module } from '@nestjs/common';
import { ScanController } from './scan.controller';
import { ScanService } from './scan.service';
import { OpenFoodFactsApiClient } from './clients/openfoodfacts-api.client';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ScanController],
  providers: [ScanService, OpenFoodFactsApiClient],
  exports: [ScanService],
})
export class ScanModule {}
