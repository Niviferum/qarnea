import { UnauthorizedException } from '@nestjs/common';
import { JwtStrategy } from './jwt.strategy';
import { PrismaService } from '../../prisma/prisma.service';

const mockPrisma = {
  utilisateur: {
    findUnique: jest.fn(),
  },
};

describe('JwtStrategy', () => {
  let strategy: JwtStrategy;

  beforeEach(() => {
    process.env.JWT_SECRET = 'test-secret';
    strategy = new JwtStrategy(mockPrisma as unknown as PrismaService);
    jest.clearAllMocks();
  });

  it('retourne l\'utilisateur si le compte est actif', async () => {
    const user = { id_utilisateur: 'uuid-1', email: 'jean@test.fr', statut_compte: 'actif' };
    mockPrisma.utilisateur.findUnique.mockResolvedValue(user);

    const result = await strategy.validate({ sub: 'uuid-1', email: 'jean@test.fr', role: 'user' as any });

    expect(result).toBe(user);
    expect(mockPrisma.utilisateur.findUnique).toHaveBeenCalledWith({
      where: { id_utilisateur: 'uuid-1' },
    });
  });

  it('leve UnauthorizedException si l\'utilisateur n\'existe pas', async () => {
    mockPrisma.utilisateur.findUnique.mockResolvedValue(null);

    await expect(
      strategy.validate({ sub: 'uuid-inexistant', email: 'x@x.fr', role: 'user' as any }),
    ).rejects.toThrow(UnauthorizedException);
  });

  it('leve UnauthorizedException si le compte est suspendu', async () => {
    mockPrisma.utilisateur.findUnique.mockResolvedValue({
      id_utilisateur: 'uuid-1',
      statut_compte: 'suspendu',
    });

    await expect(
      strategy.validate({ sub: 'uuid-1', email: 'jean@test.fr', role: 'user' as any }),
    ).rejects.toThrow(UnauthorizedException);
  });

  it('leve UnauthorizedException si le compte est desactive', async () => {
    mockPrisma.utilisateur.findUnique.mockResolvedValue({
      id_utilisateur: 'uuid-1',
      statut_compte: 'desactive',
    });

    await expect(
      strategy.validate({ sub: 'uuid-1', email: 'jean@test.fr', role: 'user' as any }),
    ).rejects.toThrow(UnauthorizedException);
  });
});
