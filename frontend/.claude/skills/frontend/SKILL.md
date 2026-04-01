---
name: frontend
description: Implémente une user story complète via un pipeline multi-agents (Notion → Architect → Scaffolder → Implementer → UI → QA → Git)
---

# Commande /frontend — Implémentation automatique d'une User Story

## Paramètres

Arguments reçus : `$ARGUMENTS`

Parse les arguments :

- Le **premier argument numérique** est le numéro de la User Story (ex: `3` → US-03)
- Si `--plan` est présent, activer le **mode plan** (afficher le plan sans exécuter)

## Pipeline d'exécution

Exécute les agents suivants **dans l'ordre**, en lisant les instructions détaillées de chaque agent dans `.claude/agents/`.

---

### Étape 1 — Notion Reader

Lis et suis les instructions de `.claude/agents/notion-reader.md`.

**Objectif** : Récupérer la user story US-{numéro} depuis Notion via le MCP Notion, parser son contenu (titre, description, critères d'acceptation, specs).

**Livrable** : Un résumé structuré de la US avec toutes les infos nécessaires à l'implémentation.

Si la US n'est pas trouvée ou est déjà marquée comme "Fait", préviens l'utilisateur et arrête.

Mets le **`Statut Front`** de la US à **"En cours"** dans Notion.

---

### Étape 2 — Architect

Lis et suis les instructions de `.claude/agents/architect.md`.

**Objectif** : Analyser la US et produire un plan d'implémentation détaillé.

**Livrable** : Liste complète de :

- Features à créer/modifier (noms pour `feature.sh`)
- Fichiers à générer (noms pour `files.sh`)
- Composants de présentation à créer
- Routes à ajouter
- Endpoints API (issus de la spec Notion)
- Composants shadcn/ui à installer

**Si `--plan` est actif** : Affiche ce plan à l'utilisateur et **STOP**. N'exécute pas les étapes suivantes.

---

### Étape 3 — Scaffolder

Lis et suis les instructions de `.claude/agents/scaffolder.md`.

**Objectif** : Créer la structure de fichiers en utilisant les scripts `feature.sh` et `files.sh`.

**Livrable** : Arborescence complète des features avec tous les fichiers de base générés.

---

### Étape 4 — Implementer

Lis et suis les instructions de `.claude/agents/implementer.md`.

**Objectif** : Écrire le code fonctionnel complet de chaque fichier généré.

**Livrable** : Code complet pour :

- DTOs (request + response)
- Entities
- API datasources (méthodes CRUD)
- Mappers (DTO → Entity)
- Repository interfaces + implémentations
- Hooks TanStack Query
- Endpoints dans `@/core/constants/endpoints.ts`
- Routes dans `@/core/constants/routes.ts` et `Router.tsx`
- Schémas Zod pour les formulaires si nécessaire

---

### Étape 5 — Shadcn Stylist

Lis et suis les instructions de `.claude/agents/shadcn-stylist.md`.

**Objectif** : Créer les pages et composants de présentation avec shadcn/ui.

**Livrable** :

- Composants shadcn installés (via `npx shadcn@latest add`)
- Pages complètes dans `presentation/pages/`
- Composants réutilisables dans `presentation/components/`
- Animations avec Motion si pertinent
- Responsive design
- Loading states, error states, empty states

---

### Étape 6 — Quality Checker

Lis et suis les instructions de `.claude/agents/quality-checker.md`.

**Objectif** : Vérifier que le code compile et respecte les conventions.

**Livrable** : Tous les checks passent :

- `npx tsc --noEmit` → 0 erreur
- `npx eslint src/` → 0 erreur
- `npx vite build` → build réussie
- Corriger les erreurs si besoin (max 3 itérations de fix)

---

### Étape 7 — Git Ops

Lis et suis les instructions de `.claude/agents/git-ops.md`.

**Objectif** : Commit, push et mettre à jour Notion.

**Livrable** :

- Commit avec message `feat(US-{numéro}): {description courte}`
- Push sur la branche courante
- Mettre le **`Statut Front`** de la US à **"Fait"** dans Notion
