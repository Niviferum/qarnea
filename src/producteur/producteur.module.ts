import { Module } from '@nestjs/common';
import { ProducteurController } from './producteur.controller';
import { ProducteurService } from './producteur.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ProducteurController],
  providers: [ProducteurService],
})
export class ProducteurModule {}
