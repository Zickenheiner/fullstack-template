# Conventions & Regles du Projet Backend

## Stack technique

- **Framework** : NestJS ^11 + TypeScript 5.7
- **Base de donnees** : MongoDB via Mongoose ^8 + @nestjs/mongoose
- **Auth** : Passport JWT (@nestjs/passport, passport-jwt) — tokens exclusivement en cookies HTTP-only
- **Hashing** : Argon2
- **Validation** : class-validator ^0.14 + class-transformer ^0.5
- **Documentation API** : @nestjs/swagger + @scalar/nestjs-api-reference
- **Securite** : express-mongo-sanitize, ValidationPipe (whitelist + transform)
- **Compiler** : SWC (@swc/core) pour les builds rapides

## Architecture — Clean Architecture par Feature

Chaque feature suit cette arborescence (generee par `feature.sh` et `files.sh`) :

```
src/features/<feature-name>/
├── domains/
│   ├── dtos/              # DTOs avec decorateurs class-validator + @ApiProperty
│   ├── schemas/           # Schemas Mongoose (@Schema, @Prop)
│   └── entities/          # Entites domaine (classe avec getters/setters)
├── interfaces/
│   ├── services/          # Interfaces service (IXxxService)
│   └── repositories/      # Interfaces repository (IXxxRepository)
├── modules/
│   ├── controllers/       # Controllers NestJS avec decorateurs Swagger
│   ├── implementation/
│   │   ├── services/      # Implementations service
│   │   ├── repositories/  # Implementations repository (Mongoose)
│   │   └── mappers/       # Mappers Document → Entity (@Injectable)
│   └── <name>.module.ts   # Module NestJS avec bindings DI
└── utils/
```

## Fichiers core existants

- `@core/guards/access-token.guard.ts` — Guard JWT global avec support `@Public()`
- `@core/guards/refresh-token.guard.ts` — Guard `jwt-refresh` a utiliser avec `@Public()` sur l'endpoint de refresh
- `@core/strategies/at.strategy.ts` — Extraction JWT depuis le cookie `access_token` uniquement
- `@core/strategies/rt.strategy.ts` — Strategie `jwt-refresh`, extraction depuis le cookie `refresh_token` (`REFRESH_TOKEN_SECRET`)
- `@core/configs/cookie.config.ts` — Noms et options des cookies d'auth (`access_token`, `refresh_token`, `logged_in`)
- `@core/services/auth-cookie.service.ts` — `setAuthCookies(res, accessToken, refreshToken)` / `clearAuthCookies(res)`
- `@core/core.module.ts` — Module global exposant `AuthCookieService`
- `@core/decorators/public.decorator.ts` — Decorateur `@Public()` pour bypasser le guard JWT
- `@core/dtos/` — Reserve pour DTOs partages
- `@core/interceptors/` — Reserve pour interceptors
- `@core/middlewares/` — Reserve pour middlewares
- `@core/pipes/` — Reserve pour pipes custom
- `@core/roles/` — Reserve pour decorateurs de roles
- `@core/tasks/` — Reserve pour taches planifiees
- `src/app.module.ts` — Module racine (ConfigModule global, MongooseModule async, CoreModule, AtStrategy, RtStrategy, APP_GUARD = AccessTokenGuard)
- `src/main.ts` — Bootstrap avec mongoSanitize, ValidationPipe, Swagger/Scalar (cookie auth `access_token`), cookieParser, CORS

## Conventions de code

### Commentaires

- **Aucun commentaire dans le code** : ne jamais ajouter de commentaires (`//`, `/* */`, JSDoc, etc.). Le code doit être auto-documenté via des noms explicites.

### Naming

- **Fichiers** : lowercase (`user.service.ts`, `user.controller.ts`, `user.schema.ts`)
- **Classes** : PascalCase (`UserService`, `UserController`)
- **Interfaces** : I prefix + PascalCase (`IUserService`, `IUserRepository`)
- **Suffixes obligatoires** :
  - `.schema.ts` pour les schemas Mongoose
  - `.entity.ts` pour les entites
  - `.dto.ts` pour les DTOs
  - `.mapper.ts` pour les mappers
  - `.repository.ts` pour les implementations repository
  - `.irepository.ts` pour les interfaces repository
  - `.service.ts` pour les implementations service
  - `.iservice.ts` pour les interfaces service
  - `.controller.ts` pour les controllers
  - `.module.ts` pour les modules

### Dependency Injection

- Les interfaces sont injectees via des **string tokens** : `@Inject('IXxxService')`
- Registration dans le module : `{ provide: 'IXxxService', useClass: XxxService }`
- Les Mappers sont injectes via leur type de classe (pas de string token)
- Les modeles Mongoose sont injectes via `@InjectModel(Xxx.name)`

### Patterns obligatoires

1. **Schema** : `@Schema({ timestamps: true })` + `@Prop()` + `SchemaFactory.createForClass()`
2. **Document type** : `XxxDocument = Xxx & Document`
3. **Entity** : Classe avec `private readonly id`, constructeur prenant le type schema, getters/setters pour chaque propriete
4. **DTOs** : Classes avec `@IsString()`, `@IsNotEmpty()`, `@ApiProperty()`, etc.
5. **Mapper** : `@Injectable()` avec methode `toEntity(doc: XxxDocument): XxxEntity`
6. **Repository interface** : `IXxxRepository` avec methodes CRUD retournant `Promise<XxxEntity[] | null>`, `Promise<boolean>`, etc.
7. **Service interface** : `IXxxService` miroir du repository
8. **Repository impl** : `@Injectable()`, utilise `@InjectModel()` + mapper
9. **Service impl** : `@Injectable()`, utilise `@Inject('IXxxRepository')`
10. **Controller** : `@Inject('IXxxService')`, decorateurs Swagger sur chaque methode (`@ApiOperation`, `@ApiResponse`, `@ApiParam`, `@ApiBody`)
11. **Module** : `MongooseModule.forFeature()`, controller, providers (mapper + service/repository via string tokens), exports service token
12. **AppModule** : Chaque feature module doit etre importe dans `src/app.module.ts`

### Validation

- `ValidationPipe` global avec `whitelist: true` et `transform: true` (deja dans `main.ts`)
- Les DTOs utilisent les decorateurs class-validator : `@IsString()`, `@IsNotEmpty()`, `@IsEmail()`, `@MinLength()`, `@IsOptional()`, etc.
- Toutes les proprietes DTO doivent avoir `@ApiProperty()` pour la documentation Swagger

### Auth

- Toutes les routes sont protegees par defaut (global `AccessTokenGuard`)
- Les routes publiques utilisent le decorateur `@Public()`
- JWT lu uniquement depuis `cookies.access_token` (aucun header `Authorization`)
- Ne jamais renvoyer les tokens dans le body : utiliser `AuthCookieService.setAuthCookies(res, accessToken, refreshToken)` (via `@Res({ passthrough: true })`)
- Logout / echec de refresh : `AuthCookieService.clearAuthCookies(res)`
- Endpoint de refresh : `POST /auth/refresh` avec `@Public()` + `@UseGuards(RefreshTokenGuard)`, sans body
- Cookies : `access_token` (httpOnly, path `/`), `refresh_token` (httpOnly, path `REFRESH_COOKIE_PATH`), `logged_in=1` (lisible JS, indicateur front) — `sameSite: strict`, `secure` si `APP_PROTOCOL=https`

### Path aliases

- `@core/*` → `src/core/*`
- `@features/*` → `src/features/*`

### Git

- Format de commit : `feat(US-XX): description courte en français`
- Un commit + push par user story completee
- Toujours verifier que `npx nest build` passe avant de commit

## Commandes disponibles

- `/backend <US-number> [--plan]` — Implemente une user story complete

## Scripts disponibles

- `./feature.sh <feature-name>` — Cree l'arborescence d'une feature + module vide
- `./files.sh <file-name> <feature-name>` — Genere les fichiers de base (entity, DTOs, schema, interfaces, mapper, repository, service, controller, module)
