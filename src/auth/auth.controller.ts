import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { Utilisateur } from '../generated/prisma';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Inscription' })
  @ApiResponse({ status: 201, description: 'Compte cree, tokens retournes' })
  @ApiResponse({ status: 409, description: 'Email deja utilise' })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Connexion' })
  @ApiResponse({ status: 200, description: 'Tokens retournes' })
  @ApiResponse({ status: 401, description: 'Identifiants invalides' })
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Renouvellement du access token via le refresh token' })
  @ApiBody({ schema: { properties: { refresh_token: { type: 'string' } } } })
  @ApiResponse({ status: 200, description: 'Nouveau couple de tokens' })
  @ApiResponse({ status: 401, description: 'Refresh token invalide ou expire' })
  refresh(@Body('refresh_token') refreshToken: string) {
    return this.authService.refresh(refreshToken);
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Deconnexion — invalide le refresh token en Redis' })
  @ApiResponse({ status: 204, description: 'Session terminee' })
  @ApiResponse({ status: 401, description: 'Non authentifie' })
  logout(@Request() req: { user: Utilisateur }) {
    return this.authService.logout(req.user.id_utilisateur);
  }
}
