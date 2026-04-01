# Conventions & Regles du Projet Backend

## Stack technique

- **Framework** : NestJS ^11 + TypeScript 5.7
- **Base de donnees** : MongoDB via Mongoose ^8 + @nestjs/mongoose
- **Auth** : Passport JWT (@nestjs/passport, passport-jwt) — extraction depuis cookies ou header Authorization
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
- `@core/strategies/at.strategy.ts` — Extraction JWT depuis cookies (`access_token`) ou header `Authorization: Bearer`
- `@core/decorators/public.decorator.ts` — Decorateur `@Public()` pour bypasser le guard JWT
- `@core/configs/` — Reserve pour fichiers de configuration
- `@core/dtos/` — Reserve pour DTOs partages
- `@core/interceptors/` — Reserve pour interceptors
- `@core/middlewares/` — Reserve pour middlewares
- `@core/pipes/` — Reserve pour pipes custom
- `@core/roles/` — Reserve pour decorateurs de roles
- `@core/tasks/` — Reserve pour taches planifiees
- `src/app.module.ts` — Module racine (ConfigModule global, MongooseModule async, APP_GUARD = AccessTokenGuard)
- `src/main.ts` — Bootstrap avec mongoSanitize, ValidationPipe, Swagger/Scalar, cookieParser, CORS

## Conventions de code

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
- JWT lu depuis `cookies.access_token` ou `Authorization: Bearer <token>`

### Path aliases

- `@core/*` → `src/core/*`
- `@features/*` → `src/features/*`

### Git

- Format de commit : `feat(US-XX): description courte en anglais`
- Un commit + push par user story completee
- Toujours verifier que `npx nest build` passe avant de commit

## Commandes disponibles

- `/backend <US-number> [--plan]` — Implemente une user story complete

## Scripts disponibles

- `./feature.sh <feature-name>` — Cree l'arborescence d'une feature + module vide
- `./files.sh <file-name> <feature-name>` — Genere les fichiers de base (entity, DTOs, schema, interfaces, mapper, repository, service, controller, module)
