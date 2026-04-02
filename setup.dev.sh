#!/bin/sh
set -e

# ── Couleurs ──────────────────────────────────────────────────────────────────
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RESET="\033[0m"

echo ""
echo "${BOLD}Setup — Configuration de l'environnement${RESET}"
echo "─────────────────────────────────────────"
echo ""

# ── Questions ─────────────────────────────────────────────────────────────────

DEFAULT_NAME=$(basename "$(cd "$(dirname "$0")" && pwd)" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
printf "${CYAN}Nom du projet${RESET} (défaut : ${BOLD}${DEFAULT_NAME}${RESET}) : "
read APP_NAME_INPUT
APP_NAME=${APP_NAME_INPUT:-$DEFAULT_NAME}
APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')



# ── Génération des secrets ────────────────────────────────────────────────────

MONGO_PASS=$(openssl rand -base64 32 | tr -d '/+=' | cut -c1-32)
ACCESS_TOKEN_SECRET=$(openssl rand -base64 64 | tr -d '\n')
REFRESH_TOKEN_SECRET=$(openssl rand -base64 64 | tr -d '\n')
COOKIE_SECRET=$(openssl rand -base64 64 | tr -d '\n')

# ── Écriture du .env ──────────────────────────────────────────────────────────

if [ -f .env ]; then
  printf "\n${BOLD}.env existe déjà. Écraser ?${RESET} (o/N) : "
  read CONFIRM
  if [ "$CONFIRM" != "o" ] && [ "$CONFIRM" != "O" ]; then
    echo "Annulé."
    exit 0
  fi
fi

cat > .env <<EOF
# ── Application ───────────────────────────────────
TZ=Europe/Paris

# ── MongoDB ───────────────────────────────────────
MONGO_USER=${APP_NAME}
MONGO_PASS=${MONGO_PASS}
MONGO_DB_NAME=${APP_NAME}
MONGO_URL=mongodb://\${MONGO_USER}:\${MONGO_PASS}@mongo:27017/\${MONGO_DB_NAME}?authSource=admin

# ── CORS / URLs ───────────────────────────────────
CORS_ORIGIN=http://localhost:3000
VITE_API_URL=http://localhost:3310

# ── JWT & Cookies ─────────────────────────────────
ACCESS_TOKEN_EXPIRATION_TIME=24h
ACCESS_TOKEN_SECRET=${ACCESS_TOKEN_SECRET}
REFRESH_TOKEN_SECRET=${REFRESH_TOKEN_SECRET}
COOKIE_SECRET=${COOKIE_SECRET}
EOF

echo ""
echo "${GREEN}✓ .env généré avec succès${RESET}"

# ── Résumé ────────────────────────────────────────────────────────────────────

echo ""
echo "  Projet   : ${BOLD}${APP_NAME}${RESET}"
echo "  URL      : ${BOLD}http://localhost:3000${RESET}"
echo "  Swagger  : ${BOLD}http://localhost:3310/api${RESET}"
echo "  Secrets  : ${GREEN}générés automatiquement${RESET}"
echo ""
echo "Lance ${BOLD}make dev-up${RESET} pour démarrer."
echo ""
