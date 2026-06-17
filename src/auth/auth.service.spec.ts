import { Test, TestingModule } from '@nestjs/testing';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS_CLIENT } from '../redis/redis.constants';

const mockUtilisateur = {
  id_utilisateur: 'uuid-1',
  email: 'jean@test.fr',
  password_hash: '$2b$12$hashedpassword',
  nom: 'Dupont',
  prenom: 'Jean',
  role: 'user',
  statut_compte: 'actif',
};

const mockPrisma = {
  utilisateur: {
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
};

const mockRedis = {
  get: jest.fn(),
  set: jest.fn(),
  del: jest.fn(),
};

const mockJwt = {
  signAsync: jest.fn(),
  verify: jest.fn(),
};

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: JwtService, useValue: mockJwt },
        { provide: REDIS_CLIENT, useValue: mockRedis },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    jest.clearAllMocks();
  });

  // ----------------------------------------------------------------
  // register
  // ----------------------------------------------------------------

  describe('register', () => {
    it('cree un compte et retourne les tokens', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(null);
      mockPrisma.utilisateur.create.mockResolvedValue(mockUtilisateur);
      mockJwt.signAsync.mockResolvedValueOnce('access').mockResolvedValueOnce('refresh');
      mockRedis.set.mockResolvedValue('OK');

      const result = await service.register({
        email: 'jean@test.fr',
        password: 'motdepasse123',
        nom: 'Dupont',
        prenom: 'Jean',
      });

      expect(mockPrisma.utilisateur.create).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ access_token: 'access', refresh_token: 'refresh' });
    });

    it('leve ConflictException si l\'email est deja utilise', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(mockUtilisateur);

      await expect(
        service.register({
          email: 'jean@test.fr',
          password: 'motdepasse123',
          nom: 'Dupont',
          prenom: 'Jean',
        }),
      ).rejects.toThrow(ConflictException);

      expect(mockPrisma.utilisateur.create).not.toHaveBeenCalled();
    });

    it('hache le mot de passe avant la creation', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(null);
      mockPrisma.utilisateur.create.mockResolvedValue(mockUtilisateur);
      mockJwt.signAsync.mockResolvedValue('token');
      mockRedis.set.mockResolvedValue('OK');

      await service.register({
        email: 'jean@test.fr',
        password: 'motdepasse123',
        nom: 'Dupont',
        prenom: 'Jean',
      });

      const createCall = mockPrisma.utilisateur.create.mock.calls[0][0];
      expect(createCall.data.password_hash).toBeDefined();
      expect(createCall.data.password_hash).not.toBe('motdepasse123');
      expect(await bcrypt.compare('motdepasse123', createCall.data.password_hash)).toBe(true);
    });

    it('ne stocke jamais le mot de passe en clair', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(null);
      mockPrisma.utilisateur.create.mockResolvedValue(mockUtilisateur);
      mockJwt.signAsync.mockResolvedValue('token');
      mockRedis.set.mockResolvedValue('OK');

      await service.register({
        email: 'jean@test.fr',
        password: 'motdepasse123',
        nom: 'Dupont',
        prenom: 'Jean',
      });

      const createCall = mockPrisma.utilisateur.create.mock.calls[0][0];
      expect(createCall.data).not.toHaveProperty('password');
      expect(createCall.data.password_hash).not.toBe('motdepasse123');
    });
  });

  // ----------------------------------------------------------------
  // login
  // ----------------------------------------------------------------

  describe('login', () => {
    it('retourne les tokens pour des identifiants valides', async () => {
      const hash = await bcrypt.hash('motdepasse123', 12);
      mockPrisma.utilisateur.findUnique.mockResolvedValue({
        ...mockUtilisateur,
        password_hash: hash,
      });
      mockPrisma.utilisateur.update.mockResolvedValue({});
      mockJwt.signAsync.mockResolvedValueOnce('access').mockResolvedValueOnce('refresh');
      mockRedis.set.mockResolvedValue('OK');

      const result = await service.login({ email: 'jean@test.fr', password: 'motdepasse123' });

      expect(result).toEqual({ access_token: 'access', refresh_token: 'refresh' });
    });

    it('leve UnauthorizedException si l\'email est inconnu', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(null);

      await expect(
        service.login({ email: 'inconnu@test.fr', password: 'motdepasse123' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('leve UnauthorizedException si le mot de passe est incorrect', async () => {
      const hash = await bcrypt.hash('autremdp', 12);
      mockPrisma.utilisateur.findUnique.mockResolvedValue({
        ...mockUtilisateur,
        password_hash: hash,
      });

      await expect(
        service.login({ email: 'jean@test.fr', password: 'motdepasse123' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('leve UnauthorizedException si le compte est suspendu', async () => {
      const hash = await bcrypt.hash('motdepasse123', 12);
      mockPrisma.utilisateur.findUnique.mockResolvedValue({
        ...mockUtilisateur,
        password_hash: hash,
        statut_compte: 'suspendu',
      });

      await expect(
        service.login({ email: 'jean@test.fr', password: 'motdepasse123' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('retourne le meme message d\'erreur pour email inconnu et mdp incorrect (enumeration protection)', async () => {
      mockPrisma.utilisateur.findUnique.mockResolvedValue(null);
      let errorEmailInconnu: UnauthorizedException | undefined;
      try {
        await service.login({ email: 'inconnu@test.fr', password: 'motdepasse123' });
      } catch (e) {
        errorEmailInconnu = e as UnauthorizedException;
      }

      const hash = await bcrypt.hash('autremdp', 12);
      mockPrisma.utilisateur.findUnique.mockResolvedValue({ ...mockUtilisateur, password_hash: hash });
      let errorMdpIncorrect: UnauthorizedException | undefined;
      try {
        await service.login({ email: 'jean@test.fr', password: 'motdepasse123' });
      } catch (e) {
        errorMdpIncorrect = e as UnauthorizedException;
      }

      expect(errorEmailInconnu?.message).toBe(errorMdpIncorrect?.message);
    });
  });

  // ----------------------------------------------------------------
  // refresh
  // ----------------------------------------------------------------

  describe('refresh', () => {
    it('retourne un nouveau couple de tokens si le refresh token est valide', async () => {
      mockJwt.verify.mockReturnValue({ sub: 'uuid-1', email: 'jean@test.fr', role: 'user' });
      mockRedis.get.mockResolvedValue('valid-refresh-token');
      mockPrisma.utilisateur.findUnique.mockResolvedValue(mockUtilisateur);
      mockJwt.signAsync.mockResolvedValueOnce('new-access').mockResolvedValueOnce('new-refresh');
      mockRedis.set.mockResolvedValue('OK');

      const result = await service.refresh('valid-refresh-token');

      expect(result).toEqual({ access_token: 'new-access', refresh_token: 'new-refresh' });
    });

    it('leve UnauthorizedException si la signature JWT est invalide', async () => {
      mockJwt.verify.mockImplementation(() => { throw new Error('invalid'); });

      await expect(service.refresh('token-invalide')).rejects.toThrow(UnauthorizedException);
    });

    it('leve UnauthorizedException si le token ne correspond pas a celui en Redis', async () => {
      mockJwt.verify.mockReturnValue({ sub: 'uuid-1', email: 'jean@test.fr', role: 'user' });
      mockRedis.get.mockResolvedValue('autre-token-en-redis');

      await expect(service.refresh('token-different')).rejects.toThrow(UnauthorizedException);
    });

    it('leve UnauthorizedException si aucun token n\'est stocke en Redis (apres logout)', async () => {
      mockJwt.verify.mockReturnValue({ sub: 'uuid-1', email: 'jean@test.fr', role: 'user' });
      mockRedis.get.mockResolvedValue(null);

      await expect(service.refresh('un-token')).rejects.toThrow(UnauthorizedException);
    });

    it('leve UnauthorizedException si le compte est suspendu au moment du refresh', async () => {
      mockJwt.verify.mockReturnValue({ sub: 'uuid-1', email: 'jean@test.fr', role: 'user' });
      mockRedis.get.mockResolvedValue('valid-refresh-token');
      mockPrisma.utilisateur.findUnique.mockResolvedValue({
        ...mockUtilisateur,
        statut_compte: 'suspendu',
      });

      await expect(service.refresh('valid-refresh-token')).rejects.toThrow(UnauthorizedException);
    });
  });

  // ----------------------------------------------------------------
  // logout
  // ----------------------------------------------------------------

  describe('logout', () => {
    it('supprime le refresh token en Redis', async () => {
      mockRedis.del.mockResolvedValue(1);

      await service.logout('uuid-1');

      expect(mockRedis.del).toHaveBeenCalledWith('refresh:uuid-1');
    });

    it('ne leve pas d\'erreur si le token n\'existe pas en Redis', async () => {
      mockRedis.del.mockResolvedValue(0);

      await expect(service.logout('uuid-inexistant')).resolves.not.toThrow();
    });
  });
});
