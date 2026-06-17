import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { Redis } from 'ioredis';
import { InjectRedis } from '../redis/redis.constants';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';

const BCRYPT_ROUNDS = 12;
const REFRESH_TOKEN_TTL_SECONDS = 7 * 24 * 60 * 60;

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    @InjectRedis() private readonly redis: Redis,
  ) {}

  async register(dto: RegisterDto): Promise<{ access_token: string; refresh_token: string }> {
    const existing = await this.prisma.utilisateur.findUnique({
      where: { email: dto.email },
    });

    if (existing) {
      throw new ConflictException('Un compte existe deja avec cet email');
    }

    const password_hash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);

    const user = await this.prisma.utilisateur.create({
      data: {
        email: dto.email,
        password_hash,
        nom: dto.nom,
        prenom: dto.prenom,
        telephone: dto.telephone,
      },
    });

    return this.generateTokens(user.id_utilisateur, user.email, user.role);
  }

  async login(dto: LoginDto): Promise<{ access_token: string; refresh_token: string }> {
    const user = await this.prisma.utilisateur.findUnique({
      where: { email: dto.email },
    });

    if (!user || user.statut_compte !== 'actif') {
      throw new UnauthorizedException('Identifiants invalides');
    }

    const passwordValid = await bcrypt.compare(dto.password, user.password_hash);

    if (!passwordValid) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    await this.prisma.utilisateur.update({
      where: { id_utilisateur: user.id_utilisateur },
      data: { date_derniere_connexion: new Date() },
    });

    return this.generateTokens(user.id_utilisateur, user.email, user.role);
  }

  async refresh(refreshToken: string): Promise<{ access_token: string; refresh_token: string }> {
    let payload: JwtPayload;

    try {
      payload = this.jwtService.verify<JwtPayload>(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET,
      });
    } catch {
      throw new UnauthorizedException('Refresh token invalide ou expire');
    }

    const stored = await this.redis.get(`refresh:${payload.sub}`);

    if (!stored || stored !== refreshToken) {
      throw new UnauthorizedException('Refresh token invalide ou expire');
    }

    const user = await this.prisma.utilisateur.findUnique({
      where: { id_utilisateur: payload.sub },
    });

    if (!user || user.statut_compte !== 'actif') {
      throw new UnauthorizedException('Refresh token invalide ou expire');
    }

    return this.generateTokens(user.id_utilisateur, user.email, user.role);
  }

  async logout(userId: string): Promise<void> {
    await this.redis.del(`refresh:${userId}`);
  }

  private async generateTokens(
    userId: string,
    email: string,
    role: string,
  ): Promise<{ access_token: string; refresh_token: string }> {
    const payload: JwtPayload = { sub: userId, email, role: role as JwtPayload['role'] };

    const [access_token, refresh_token] = await Promise.all([
      this.jwtService.signAsync(payload),
      this.jwtService.signAsync(payload, {
        secret: process.env.JWT_REFRESH_SECRET,
        expiresIn: (process.env.JWT_REFRESH_EXPIRES_IN ?? '7d') as any,
      }),
    ]);

    await this.redis.set(
      `refresh:${userId}`,
      refresh_token,
      'EX',
      REFRESH_TOKEN_TTL_SECONDS,
    );

    return { access_token, refresh_token };
  }
}
