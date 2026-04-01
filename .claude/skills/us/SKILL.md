---
name: us
description: Implémente une user story complète full-stack en lançant simultanément les pipelines /backend ET /frontend en parallèle. Utiliser quand l'utilisateur veut implémenter une US complète des deux côtés, ex: "/us 03" exécute le pipeline backend ET le pipeline frontend pour la US-03 en même temps. Aussi déclenché par "implémente la US X", "lance la US X full-stack", "démarre la US X".
argument-hint: <numéro de US> [--plan]
---

# Commande /us — Implémentation Full-Stack d'une User Story

## Paramètres

Arguments reçus : `$ARGUMENTS`

Parse les arguments :

- Le **premier argument numérique** est le numéro de la User Story (ex: `03`)
- Si `--plan` est présent, le transmettre aux deux pipelines

## Exécution parallèle

Lance **deux agents en parallèle** dans le même appel d'outil Agent :

### Agent 1 — Backend

- Répertoire de travail : `backend/`
- Lis et suis intégralement les instructions de `backend/.claude/skills/backend/SKILL.md`
- Remplace `$ARGUMENTS` par les arguments reçus (ex: `03` ou `03 --plan`)

### Agent 2 — Frontend

- Répertoire de travail : `frontend/`
- Lis et suis intégralement les instructions de `frontend/.claude/skills/frontend/SKILL.md`
- Remplace `$ARGUMENTS` par les arguments reçus (ex: `03` ou `03 --plan`)

Les deux agents s'exécutent indépendamment et simultanément. Attends que les deux soient terminés avant de faire un rapport final à l'utilisateur.

## Rapport final

Une fois les deux agents terminés, résume brièvement :

- ✅ ou ❌ Backend : résultat
- ✅ ou ❌ Frontend : résultat
- Tout problème rencontré
