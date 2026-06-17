# Qarnea — API Backend

API REST NestJS pour la mise en relation entre consommateurs et producteurs locaux via scan de code-barres.

---

## Stack technique

- **NestJS 11** + TypeScript
- **Prisma 7** + PostgreSQL + PostGIS
- **Redis** (ioredis) — sessions refresh token
- **Stripe** — gestion des abonnements
- **Passport JWT** — authentification
- **bcrypt** — hashage des mots de passe

---

## Demarrage

### Prerequis

- Node.js >= 20
- PostgreSQL avec extension PostGIS
- Redis

### Installation

```bash
npm install
```

### Variables d'environnement

Copier `.env.example` en `.env` et renseigner les valeurs :

```env
DATABASE_URL=postgresql://user:password@localhost:5432/qarnea?schema=public

JWT_SECRET=
JWT_REFRESH_SECRET=
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

REDIS_URL=redis://localhost:6379
```

### Migrations

```bash
npx prisma migrate deploy
npx prisma generate
```

### Lancement

```bash
# developpement
npm run start:dev

# production
npm run build
npm run start:prod
```

---

## Architecture

### Modele general

Layered architecture par domaine metier (feature-based). Chaque domaine est un module NestJS autonome avec ses propres couches.

```
HTTP Request
     |
     v
[ Controller ]   -- interface HTTP uniquement, aucune logique metier
     |
     v
[  Service   ]   -- logique metier, orchestration
     |
   /   \
  v     v
[Prisma] [Redis]  -- acces aux donnees, pas de logique metier
```

### Modules implementes

| Module | Responsabilite |
|---|---|
| `PrismaModule` | Client Prisma injectable globalement |
| `RedisModule` | Client Redis injectable globalement |
| `AuthModule` | Inscription, connexion, JWT, refresh token, guards |
| `UtilisateurModule` | Profil, mise a jour, localisation, suppression de compte |

### Modules a venir

```
Producteur -> Scan OFF -> Alternatives -> Recherche -> Stripe -> Notifications -> Admin
```

---

## Authentification

### Mecanisme

- **Access token** : JWT signe, expire apres 15 min (configurable via `JWT_EXPIRES_IN`)
- **Refresh token** : JWT signe avec un secret distinct, expire apres 7 jours, stocke en Redis

Le stockage Redis du refresh token permet l'invalidation immediate lors du logout ou d'une suspension de compte — impossible avec un JWT purement stateless.

### Flux

```
POST /auth/register  --> { access_token, refresh_token }
POST /auth/login     --> { access_token, refresh_token }
POST /auth/refresh   --> { access_token, refresh_token }  (rotation du refresh token)
POST /auth/logout    --> 204 No Content                   (suppression Redis)
```

### Rotation du refresh token

A chaque appel sur `/auth/refresh`, un nouveau couple de tokens est emis et le refresh token precedent est ecrase en Redis. Un refresh token utilise une seule fois est donc invalide apres rotation.

### Protection des routes

```typescript
// Route accessible aux utilisateurs authentifies
@UseGuards(JwtAuthGuard)

// Route reservee aux admins
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.admin)
```

---

## Securite

- Mots de passe haches avec **bcrypt** (12 rounds)
- Secrets JWT distincts pour access et refresh token
- Validation stricte des DTOs (`whitelist: true`, `forbidNonWhitelisted: true`)
- Message d'erreur identique pour email inconnu et mot de passe incorrect (protection contre l'enumeration)
- Headers HTTP securises via **Helmet**

---

## Tests

### Methodologie

Le projet suit une approche **TDD** a partir du module Producteur : les specs sont ecrites avant le code, validees, puis implementees.

### Lancer les tests

```bash
# tests unitaires
npm run test

# couverture
npm run test:cov

# tests e2e
npm run test:e2e
```

### Suites existantes

#### `auth.service.spec.ts` — 16 tests

| Groupe | Cas testes |
|---|---|
| `register` | Creation de compte, email deja utilise, hashage bcrypt, absence du mot de passe en clair |
| `login` | Identifiants valides, email inconnu, mot de passe incorrect, compte suspendu, message d'erreur identique (protection enumeration) |
| `refresh` | Token valide, signature invalide, token different de Redis, absent de Redis (post-logout), compte suspendu |
| `logout` | Suppression Redis, idempotence si le token n'existe pas |

#### `roles.guard.spec.ts` — 7 tests

Roles non requis, liste vide, role correct, plusieurs roles autorises, role insuffisant, message de l'exception, lecture des metadonnees handler/controller.

#### `jwt.strategy.spec.ts` — 4 tests

Utilisateur actif retourne, utilisateur inexistant, compte suspendu, compte desactive.

#### `utilisateur.service.spec.ts` — 13 tests

| Groupe | Cas testes |
|---|---|
| `getProfil` | Retour du profil, utilisateur introuvable, absence de `password_hash` et `stripe_customer_id` en reponse |
| `updateProfil` | Mise a jour, conversion `date_naissance` string → Date, absence du champ si non fourni |
| `updateLocalisation` | Mise a jour des coordonnees, valeur par defaut de `localisation_autorisee`, valeur explicite |
| `supprimerCompte` | Suppression, retour void |

---

## Principes de developpement

- **TDD** : specs ecrites avant le code a partir du module Producteur
- **SOLID** : chaque fichier a une responsabilite unique, les dependances sont injectees
- **KISS** : pas d'abstraction sans besoin demonstre
- Un module ne peut pas acceder aux couches internes d'un autre module (seuls les exports sont consommables)
