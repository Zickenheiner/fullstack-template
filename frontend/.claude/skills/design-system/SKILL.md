---
name: design-system
description: Configure le design system complet depuis la charte graphique Notion (couleurs, typographies, variables CSS, shadcn/ui)
---

# Commande /design-system — Configuration du Design System depuis Notion

## Objectif

Cette commande est à lancer **une seule fois** au début d'un projet. Elle récupère la charte graphique depuis la page Notion du projet et configure tout le design system du projet.

## Étape 1 — Récupérer la charte graphique

Utilise le MCP Notion pour :

1. Chercher la page "Charte Graphique" (ou "Design System") dans l'espace de travail Notion courant
2. Lire tout le contenu de la page : couleurs, typographies, espacements, border-radius, ombres, etc.

La charte Notion contient typiquement :

- **Couleurs** : primaire, secondaire, accent, background, surface, texte, success, warning, error, info — avec leurs variantes (light, dark, hover, etc.)
- **Typographies** : font families, tailles (h1 à body/small), poids, line-height
- **Espacements** : padding/margin tokens si définis
- **Border radius** : valeurs de coins arrondis
- **Ombres** : niveaux d'ombrage si définis

## Étape 2 — Mettre à jour index.css

Ouvre `src/index.css` et configure les variables CSS au format Tailwind CSS v4.

Le fichier doit suivre cette structure :

```css
@import 'tailwindcss';
@import 'tw-animate-css';

@custom-variant dark (&:is(.dark *));

/* Fonts */
@import '@fontsource-variable/dm-sans';
@import '@fontsource-variable/geist';
@import '@fontsource/jetbrains-mono';

:root {
  /* === Couleurs — mappées depuis la charte Notion === */

  /* Couleurs de base */
  --background: <valeur oklch ou hex>;
  --foreground: <valeur>;

  /* Couleurs de carte/surface */
  --card: <valeur>;
  --card-foreground: <valeur>;

  /* Popover */
  --popover: <valeur>;
  --popover-foreground: <valeur>;

  /* Couleurs primaires (action principale) */
  --primary: <valeur>;
  --primary-foreground: <valeur>;

  /* Couleurs secondaires */
  --secondary: <valeur>;
  --secondary-foreground: <valeur>;

  /* Muted (éléments discrets) */
  --muted: <valeur>;
  --muted-foreground: <valeur>;

  /* Accent */
  --accent: <valeur>;
  --accent-foreground: <valeur>;

  /* États sémantiques */
  --destructive: <valeur>;
  --destructive-foreground: <valeur>;
  --success: <valeur>;
  --success-foreground: <valeur>;
  --warning: <valeur>;
  --warning-foreground: <valeur>;
  --info: <valeur>;
  --info-foreground: <valeur>;

  /* Bordures & inputs */
  --border: <valeur>;
  --input: <valeur>;
  --ring: <valeur>;

  /* Border radius */
  --radius: <valeur, ex: 0.625rem>;

  /* Typographie */
  --font-sans: 'DM Sans Variable', 'Geist Variable', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', ui-monospace, monospace;

  /* Sidebar (si applicable) */
  --sidebar: <valeur>;
  --sidebar-foreground: <valeur>;
  --sidebar-primary: <valeur>;
  --sidebar-primary-foreground: <valeur>;
  --sidebar-accent: <valeur>;
  --sidebar-accent-foreground: <valeur>;
  --sidebar-border: <valeur>;
  --sidebar-ring: <valeur>;
}

.dark {
  /* Toutes les mêmes variables avec les valeurs dark mode */
  --background: <valeur dark>;
  /* ... */
}
```

Adapte les noms de variables et les valeurs en fonction de ce que contient la charte Notion. Si la charte ne définit pas de dark mode, génère des valeurs dark cohérentes.

## Étape 3 — Configurer shadcn/ui

Vérifie que `components.json` existe et est correctement configuré pour utiliser les variables CSS définies ci-dessus. Si le fichier n'existe pas, lance `npx shadcn@latest init` avec les bons paramètres.

## Étape 4 — Vérification

- Vérifie que `npx vite build` passe sans erreur
- Affiche un résumé des tokens configurés à l'utilisateur
