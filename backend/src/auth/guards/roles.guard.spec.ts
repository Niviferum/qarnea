import { ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ExecutionContext } from '@nestjs/common';
import { RolesGuard } from './roles.guard';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { Role } from '../../generated/prisma';

function buildContext(user: object, handler = {}, controller = {}): ExecutionContext {
  return {
    getHandler: () => handler,
    getClass: () => controller,
    switchToHttp: () => ({
      getRequest: () => ({ user }),
    }),
  } as unknown as ExecutionContext;
}

describe('RolesGuard', () => {
  let guard: RolesGuard;
  let reflector: Reflector;

  beforeEach(() => {
    reflector = new Reflector();
    guard = new RolesGuard(reflector);
  });

  it('autorise si aucun role n\'est requis', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(undefined);
    const ctx = buildContext({ role: Role.user });

    expect(guard.canActivate(ctx)).toBe(true);
  });

  it('autorise si la liste de roles requis est vide', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([]);
    const ctx = buildContext({ role: Role.user });

    expect(guard.canActivate(ctx)).toBe(true);
  });

  it('autorise un utilisateur avec le role correct', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([Role.admin]);
    const ctx = buildContext({ role: Role.admin });

    expect(guard.canActivate(ctx)).toBe(true);
  });

  it('autorise si l\'utilisateur a l\'un des roles autorises', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([Role.admin, Role.producteur]);
    const ctx = buildContext({ role: Role.producteur });

    expect(guard.canActivate(ctx)).toBe(true);
  });

  it('leve ForbiddenException si le role ne correspond pas', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([Role.admin]);
    const ctx = buildContext({ role: Role.user });

    expect(() => guard.canActivate(ctx)).toThrow(ForbiddenException);
  });

  it('leve ForbiddenException pour un role user tentant d\'acceder a une route admin', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([Role.admin]);
    const ctx = buildContext({ role: Role.user });

    expect(() => guard.canActivate(ctx)).toThrow('Acces refuse');
  });

  it('lit les metadonnees depuis le handler et le controller', () => {
    const spy = jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([Role.admin]);
    const handler = {};
    const controller = {};
    const ctx = buildContext({ role: Role.admin }, handler, controller);

    guard.canActivate(ctx);

    expect(spy).toHaveBeenCalledWith(ROLES_KEY, [handler, controller]);
  });
});
