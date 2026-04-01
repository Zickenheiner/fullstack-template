# Conventions & Règles du Projet Frontend

## Stack technique

- **Framework** : React 19 + TypeScript strict
- **Build** : Vite 7
- **Routing** : React Router DOM v7
- **State serveur** : TanStack React Query v5
- **State client** : Zustand v5
- **Formulaires** : React Hook Form v7 + Zod v4
- **UI** : shadcn/ui v4 + Radix UI + Tailwind CSS v4
- **Animations** : Motion (Framer Motion v12)
- **Icônes** : Lucide React
- **Typographies** : @fontsource-variable/dm-sans, @fontsource-variable/geist, @fontsource/jetbrains-mono

## Architecture — Clean Architecture par Feature

Chaque feature suit cette arborescence (générée par `feature.sh` et `files.sh`) :

```
src/features/<feature-name>/
├── data/
│   ├── datasources/       # Appels API (classes avec méthodes HTTP)
│   ├── repositories/      # Implémentations concrètes des repositories
│   ├── mappers/           # DTO → Entity
│   └── dtos/              # Types des réponses/requêtes API
├── domain/
│   ├── repositories/      # Interfaces (contrats)
│   ├── entities/          # Types métier
│   └── hooks/             # Hooks React (TanStack Query, logique métier)
└── presentation/
    ├── pages/             # Composants page (rattachés au router)
    └── components/        # Composants UI spécifiques à la feature
```

## Fichiers core existants

- `@/core/config/api.ts` — Wrapper `request<T>(config)` avec refresh token automatique
- `@/core/config/queryClient.ts` — Instance TanStack Query
- `@/core/constants/endpoints.ts` — Objet des URLs d'API par entité
- `@/core/constants/methods.ts` — Constantes HTTP (GET, POST, PATCH, DELETE)
- `@/core/constants/routes.ts` — Constantes des routes frontend
- `@/core/local/storage.ts` — Gestion tokens (access/refresh) via react-secure-storage
- `@/core/utils/jwt.ts` — Vérification expiration token
- `@/core/errors/api.error.ts` — Classe ApiError custom
- `@/core/types/query.type.ts` — Type QueryParams

## Conventions de code

### Naming

- **Fichiers** : kebab-case (`user-profile.hook.ts`, `user-profile.entity.ts`)
- **Composants** : PascalCase (`UserProfilePage.tsx`, `UserCard.tsx`)
- **Hooks** : camelCase préfixé `use` (`useUserProfile`, `useCreateTransaction`)
- **Classes** : PascalCase (`UserApi`, `UserRepositoryImpl`, `UserMapper`)
- **Interfaces** : PascalCase (`UserEntity`, `UserRepository`, `UserResponseDto`)
- **Suffixes obligatoires** :
  - `.api.ts` pour les datasources
  - `.repository.impl.ts` pour les implémentations
  - `.repository.ts` pour les interfaces
  - `.mapper.ts` pour les mappers
  - `.dto.ts` pour les DTOs
  - `.entity.ts` pour les entités
  - `.hook.ts` pour les hooks

### Patterns obligatoires

1. **API Datasource** : Classe avec `private readonly baseUrl` initialisé via `endpoints`
2. **Repository** : Interface dans `domain/`, implémentation dans `data/` qui utilise l'API + le mapper
3. **Mapper** : Méthode `toEntity(dto)` qui transforme le DTO en Entity
4. **Hooks** : Utiliser `useQuery` / `useMutation` de TanStack Query, instancier le repository dans le hook
5. **Pages** : Un seul composant page par route, qui orchestre les hooks et les composants
6. **Formulaires** : React Hook Form + Zod schema, toujours valider côté client
7. **Requêtes API** : Toujours utiliser le wrapper `request` de `@/core/config/api.ts`

### API & Backend

L'API backend n'existe pas encore. Les agents doivent :

- Inventer les DTOs (request/response) en se basant sur les besoins de la US
- Créer les entities avec les champs nécessaires
- Implémenter les hooks avec de vrais appels API (le backend sera créé après)
- Ajouter les endpoints dans `@/core/constants/endpoints.ts`

### Routing

- Les routes publiques passent par le composant `Public` (redirige si authentifié)
- Les routes privées passent par `Private` + `Layout` (redirige si non authentifié)
- Ajouter les nouvelles routes dans `@/core/constants/routes.ts` ET dans `src/app/Router.tsx`

### shadcn/ui

- Installer les composants à la demande avec `npx shadcn@latest add <component>`
- Tous les composants shadcn vont dans `src/components/ui/`
- Utiliser les composants shadcn comme base, customiser avec Tailwind
- Respecter la charte graphique définie dans `index.css` (couleurs, typographies, border-radius)

### Styling

- Tailwind CSS v4 avec variables CSS custom dans `index.css`
- Utiliser `cn()` (clsx + tailwind-merge) pour les classes conditionnelles
- Animations avec Motion (`motion` package) pour les transitions complexes
- `tw-animate-css` pour les animations Tailwind de base

### Git

- Format de commit : `feat(US-XX): description courte en anglais`
- Un commit + push par user story complétée
- Toujours vérifier que `tsc --noEmit` et `eslint` passent avant de commit

## Commandes disponibles

- `/frontend <US-number> [--plan]` — Implémente une user story complète
- `/design-system` — Configure le design system depuis la charte graphique Notion

## Scripts disponibles

- `./feature.sh <feature-name>` — Crée l'arborescence d'une feature
- `./files.sh <file-name> <feature-name>` — Génère les fichiers de base (API, repo, mapper, DTO, entity, hook)
