# Template Fullstack

Template de démarrage pour une application web fullstack avec authentification JWT, prêt pour le développement local et le déploiement en production.

## Stack technique

| Couche              | Technologie                                             |
| ------------------- | ------------------------------------------------------- |
| **Frontend**        | React 19, TypeScript, Vite 7                            |
| **UI**              | shadcn/ui, Tailwind CSS v4, Radix UI, Motion            |
| **State / Forms**   | TanStack Query v5, Zustand v5, React Hook Form + Zod v4 |
| **Backend**         | NestJS 11, TypeScript, SWC                              |
| **Base de données** | MongoDB 7 (dev) / 4.4 (prod) via Mongoose 8             |
| **Auth**            | JWT (access + refresh) dans cookies HTTP-only           |
| **Reverse proxy**   | Caddy (TLS automatique via Let's Encrypt)               |
| **Conteneurs**      | Docker Compose                                          |

---

## Prérequis

- [Docker](https://www.docker.com/) & Docker Compose
- `make`
- `openssl` (présent par défaut sur macOS/Linux)

---

## Développement local

### 1. Configurer l'environnement

```bash
make dev-setup
```

Ce script interactif (`setup.dev.sh`) génère un fichier `.env` à la racine. Il demande uniquement le **nom du projet** (défaut : nom du dossier courant) puis génère automatiquement :

- les identifiants MongoDB (mot de passe généré aléatoirement)
- les secrets JWT et cookies (générés via `openssl rand`)
- les URLs configurées pour localhost

Contenu du `.env` généré :

```env
TZ=Europe/Paris

MONGO_USER=mon-projet
MONGO_PASS=<généré>
MONGO_DB_NAME=mon-projet
MONGO_URL=mongodb://${MONGO_USER}:${MONGO_PASS}@mongo:27017/${MONGO_DB_NAME}?authSource=admin

CORS_ORIGIN=http://localhost:3000
VITE_API_URL=http://localhost:3310

ACCESS_TOKEN_EXPIRATION_TIME=24h
ACCESS_TOKEN_SECRET=<généré>
REFRESH_TOKEN_SECRET=<généré>
COOKIE_SECRET=<généré>
```

### 2. Démarrer les services

```bash
make dev-up
```

Trois conteneurs démarrent sur le réseau interne `app` :

| Service      | URL locale            | Description                            |
| ------------ | --------------------- | -------------------------------------- |
| **Frontend** | http://localhost:3000 | Vite avec HMR (Hot Module Replacement) |
| **Backend**  | http://localhost:3310 | NestJS en watch mode                   |
| **MongoDB**  | `localhost:27017`     | Exposé uniquement sur 127.0.0.1        |

Pour afficher l'URL MongoDB Compass :

```bash
make dev-compass
```

URL Compass : `mongodb://<MONGO_USER>:<MONGO_PASS>@localhost:27017/<MONGO_DB_NAME>?authSource=admin`

### Hot reload

Le code source est monté directement dans les conteneurs via des volumes Docker :

- **Backend** : NestJS watch mode (`nest start --watch`) — rechargement automatique à chaque modification TypeScript
- **Frontend** : Vite HMR — mise à jour instantané dans le navigateur sans rechargement de page

```
./backend  →  monté dans /app du conteneur backend
./frontend →  monté dans /app du conteneur frontend
```

Les `node_modules` sont dans un volume anonyme séparé pour éviter les conflits de permissions entre le host et Docker.

### Documentation API

La documentation Swagger interactive (Scalar) est disponible en développement à :

```
http://localhost:3310/api
```

### Commandes de développement

```bash
make dev-logs              # Logs de tous les services (suivi actif)
make dev-logs-backend      # Logs du backend uniquement
make dev-logs-frontend     # Logs du frontend uniquement
make dev-logs-mongo        # Logs MongoDB

make dev-sh-backend        # Shell interactif dans le conteneur backend
make dev-sh-frontend       # Shell interactif dans le conteneur frontend
make mongo-sh-dev          # Shell mongosh (avec authentification)

make dev-down              # Arrêter tous les services
```

---

## Structure du projet

```
.
├── backend/                # API NestJS
│   ├── src/
│   │   ├── app.module.ts   # Module racine (ConfigModule, MongooseModule, JWT Guard global)
│   │   ├── main.ts         # Bootstrap (CORS, ValidationPipe, Swagger, cookieParser)
│   │   ├── core/           # Guards, strategies, decorators partagés
│   │   └── features/       # Features de l'application
│   ├── Dockerfile.dev
│   ├── Dockerfile.prod
│   └── package.json
│
├── frontend/               # App React
│   ├── src/
│   │   ├── app/            # Router, Provider (TanStack Query)
│   │   ├── core/           # Config API, endpoints, routes, utils
│   │   └── features/       # Features de l'application
│   ├── nginx.conf          # Config Nginx pour la prod (SPA fallback, gzip, cache)
│   ├── Dockerfile.dev
│   ├── Dockerfile.prod
│   └── package.json
│
├── docker-compose.dev.yml  # Stack développement (volumes, hot-reload)
├── docker-compose.prod.yml # Stack production (multi-stage, réseau proxy)
├── Caddyfile               # Config reverse proxy (référence)
├── Makefile                # Commandes dev & prod
├── setup.dev.sh            # Script de configuration développement
└── setup.prod.sh           # Script de configuration production
```

### Architecture par feature — Backend

```
src/features/<feature>/
├── domains/
│   ├── dtos/               # Validation (class-validator) + documentation (Swagger)
│   ├── schemas/            # Schémas Mongoose (@Schema, @Prop)
│   └── entities/           # Entités domaine (classes avec getters/setters)
├── interfaces/
│   ├── services/           # Contrats service (IXxxService)
│   └── repositories/       # Contrats repository (IXxxRepository)
└── modules/
    ├── controllers/         # Controllers NestJS + décorateurs Swagger
    ├── implementation/
    │   ├── services/        # Implémentations service
    │   ├── repositories/    # Implémentations repository (Mongoose)
    │   └── mappers/         # Document Mongoose → Entity
    └── <feature>.module.ts  # Module NestJS + bindings DI (string tokens)
```

Scripts de scaffolding dans `backend/` :

```bash
./feature.sh <nom>               # Crée l'arborescence d'une feature
./files.sh <fichier> <feature>   # Génère les fichiers de base (entity, DTOs, schema, interfaces, mapper, repository, service, controller, module)
```

### Architecture par feature — Frontend

```
src/features/<feature>/
├── data/
│   ├── datasources/        # Appels HTTP (classes avec méthodes d'API)
│   ├── repositories/       # Implémentations concrètes
│   ├── mappers/            # DTO → Entity
│   └── dtos/               # Types des réponses/requêtes API
├── domain/
│   ├── repositories/       # Interfaces (contrats)
│   ├── entities/           # Types métier
│   └── hooks/              # Hooks TanStack Query
└── presentation/
    ├── pages/              # Composants page (rattachés au router)
    └── components/         # Composants UI spécifiques à la feature
```

Scripts de scaffolding dans `frontend/` :

```bash
./feature.sh <nom>               # Crée l'arborescence d'une feature
./files.sh <fichier> <feature>   # Génère les fichiers de base (API, repo, mapper, DTO, entity, hook)
```

---

## Mise en production

### Architecture de déploiement

La production repose sur un **reverse proxy Caddy partagé** entre toutes les applications du serveur. Chaque application déclare son propre bloc de routage dans un fichier `.caddy`.

```
Internet → Caddy (réseau Docker : proxy)
               ├── monapp.example.com → frontend:80 (Nginx)
               │                        backend:3310 (routes /api/*)
               └── autreapp.example.com → ...
```

Les routes sont distribuées par Caddy :

- `/api/*` → backend NestJS (le préfixe `/api` est retiré avant le proxy)
- `/*` → frontend Nginx (fichiers statiques compilés par Vite)

### Prérequis serveur

- Un serveur Linux avec Docker installé
- Un nom de domaine pointant vers le serveur (ex : via DuckDNS)
- Le réseau Docker `proxy` créé **une seule fois** sur le serveur :
  ```bash
  docker network create proxy
  ```
- Le stack reverse-proxy Caddy déployé dans `../reverse-proxy`

### 1. Cloner le projet sur le serveur

```bash
git clone <url-du-repo> mon-projet
cd mon-projet
```

### 2. Configurer l'environnement de production

```bash
make setup
```

Le script demande :

| Question             | Exemple            | Description                                              |
| -------------------- | ------------------ | -------------------------------------------------------- |
| Nom du projet        | `monapp`           | Préfixe des conteneurs Docker et nom utilisateur MongoDB |
| Sous-domaine         | `app`              | Laisser vide si aucun                                    |
| Domaine              | `example.com`      | Défaut : `duckdns.org`                                   |
| Chemin reverse-proxy | `../reverse-proxy` | Dossier du Caddy partagé                                 |

Le script génère automatiquement :

- **`.env`** avec tous les secrets (MongoDB, JWT, cookies) et les URLs HTTPS
- **`<nom>.caddy`** dans `../reverse-proxy/conf.d/` avec la configuration de routage
- **Reload Caddy** automatiquement si le stack proxy tourne déjà

Contenu du `.env` généré en production :

```env
TZ=Europe/Paris

MONGO_USER=monapp
MONGO_PASS=<généré>
MONGO_DB_NAME=monapp
MONGO_URL=mongodb://${MONGO_USER}:${MONGO_PASS}@mongo:27017/${MONGO_DB_NAME}?authSource=admin

COMPOSE_PROJECT_NAME=monapp
PROXY_PATH=../reverse-proxy

APP_HOST=monapp.example.com

CORS_ORIGIN=https://monapp.example.com
VITE_API_URL=https://monapp.example.com/api/

ACCESS_TOKEN_EXPIRATION_TIME=1h
ACCESS_TOKEN_SECRET=<généré>
REFRESH_TOKEN_SECRET=<généré>
COOKIE_SECRET=<généré>
```

> Note : `VITE_API_URL` est injectée **au moment du build** du conteneur frontend (pas au runtime). C'est un `ARG` Docker passé à Vite lors de la compilation.

### 3. Démarrer l'application

```bash
make up
```

Les conteneurs démarrent en mode `restart: unless-stopped` avec les images compilées en multi-stage :

- **Backend** : TypeScript compilé vers `dist/`, exécuté avec `node dist/main` (pas de devDeps, utilisateur non-root)
- **Frontend** : Vite build → fichiers statiques servis par Nginx Alpine
- **MongoDB** : pas de port exposé, accessible uniquement sur le réseau `app` interne

### 4. Déployer une mise à jour

```bash
make deploy
```

Équivalent à `git pull` suivi d'un rebuild et redémarrage des conteneurs.

### 5. Commandes de production

```bash
make logs              # Logs de tous les services (suivi actif)
make logs-backend      # Logs du backend
make logs-frontend     # Logs du frontend

make sh-backend        # Shell dans le conteneur backend
make sh-frontend       # Shell dans le conteneur frontend
make mongo-sh          # Shell mongosh (avec authentification)

make restart           # Redémarrer tous les services
make down              # Arrêter tous les services
```

### Ce qui change entre dev et prod

| Aspect               | Développement                          | Production                                 |
| -------------------- | -------------------------------------- | ------------------------------------------ |
| **Images**           | Simple stage, code source monté        | Multi-stage, artefacts compilés uniquement |
| **Backend**          | `nest start --watch` (hot reload)      | `node dist/main` (build optimisé)          |
| **Frontend**         | Vite dev server (HMR)                  | Nginx servant les fichiers statiques       |
| **MongoDB**          | Port fixe `27017` exposé sur localhost | Aucun port exposé                          |
| **Réseau**           | Bridge `app` uniquement                | Bridge `app` + réseau `proxy` externe      |
| **CORS / URLs**      | `http://localhost`                     | `https://votre-domaine.com`                |
| **Token expiration** | 24h                                    | 1h                                         |
| **Accès**            | Ports directs (3000, 3310)             | Via Caddy uniquement (HTTPS)               |

---

## Variables d'environnement

| Variable                       | Description                                 | Exemple                                  |
| ------------------------------ | ------------------------------------------- | ---------------------------------------- |
| `TZ`                           | Fuseau horaire                              | `Europe/Paris`                           |
| `MONGO_USER`                   | Utilisateur MongoDB                         | `monapp`                                 |
| `MONGO_PASS`                   | Mot de passe MongoDB                        | _(généré)_                               |
| `MONGO_DB_NAME`                | Nom de la base de données                   | `monapp`                                 |
| `MONGO_URL`                    | URI de connexion complète                   | _(construite depuis les vars ci-dessus)_ |
| `COMPOSE_PROJECT_NAME`         | Préfixe des noms de conteneurs Docker       | `monapp`                                 |
| `APP_HOST`                     | Domaine de l'application                    | `monapp.duckdns.org`                     |
| `CORS_ORIGIN`                  | Origine autorisée pour le CORS              | `https://monapp.duckdns.org`             |
| `VITE_API_URL`                 | URL de l'API côté frontend (baked au build) | `https://monapp.duckdns.org/api/`        |
| `ACCESS_TOKEN_SECRET`          | Clé secrète JWT access token                | _(généré)_                               |
| `REFRESH_TOKEN_SECRET`         | Clé secrète JWT refresh token               | _(généré)_                               |
| `COOKIE_SECRET`                | Clé de signature des cookies                | _(généré)_                               |
| `ACCESS_TOKEN_EXPIRATION_TIME` | Durée de vie de l'access token              | `1h` (prod) / `24h` (dev)                |

> Le fichier `.env` est dans le `.gitignore`. Ne jamais le commiter.

---

## GitHub Actions

Le workflow `.github/workflows/deploy.yml` se déclenche automatiquement à chaque push sur `main` et déploie l'application sur le VPS via SSH.

### 1. Créer une clé SSH dédiée

Ne pas réutiliser une clé personnelle existante. Créer une paire dédiée au déploiement depuis ta machine locale :

```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_deploy
```

Laisser la passphrase vide (GitHub Actions ne peut pas la saisir).

Ensuite, autoriser cette clé sur le VPS :

```bash
ssh-copy-id -i ~/.ssh/github_actions_deploy.pub <USER>@<VPS_HOST>
```

Ou manuellement, ajouter le contenu de `~/.ssh/github_actions_deploy.pub` à `~/.ssh/authorized_keys` sur le VPS.

### 2. Configurer les secrets

À configurer dans **Settings → Secrets and variables → Actions** du dépôt GitHub :

| Secret        | Description                                                                                                                                         |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `VPS_HOST`    | Adresse IP ou domaine du VPS                                                                                                                        |
| `VPS_USER`    | Utilisateur SSH (ex : `ubuntu`, `root`)                                                                                                             |
| `VPS_SSH_KEY` | Contenu **intégral** de `~/.ssh/github_actions_deploy`, de `-----BEGIN OPENSSH PRIVATE KEY-----` jusqu'à `-----END OPENSSH PRIVATE KEY-----` inclus |
| `VPS_PATH`    | Chemin absolu du projet sur le VPS (ex : `/home/ubuntu/mon-projet`)                                                                                 |

### Fonctionnement

1. Se connecte au VPS via SSH avec la clé dédiée
2. Exécute `make deploy` dans le dossier du projet (`git pull` + rebuild des conteneurs)
