import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { AuthModule } from './auth/auth.module';
import { UtilisateurModule } from './utilisateur/utilisateur.module';
import { ProducteurModule } from './producteur/producteur.module';
import { AgenceBioModule } from './agence-bio/agence-bio.module';
import { ScanModule } from './scan/scan.module';

@Module({
  imports: [
    PrismaModule,
    RedisModule,
    AuthModule,
    UtilisateurModule,
    ProducteurModule,
    AgenceBioModule,
    ScanModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
