#!/bin/sh
set -e

# ── Couleurs ──────────────────────────────────────────────────────────────────
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RESET="\033[0m"

echo ""
echo "${BOLD}Setup — Configuration de l'environnement${RESET}"
echo "─────────────────────────────────────────"
echo ""

# ── Questions ─────────────────────────────────────────────────────────────────

printf "${CYAN}Nom du projet${RESET} (ex: myapp) : "
read APP_NAME
APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

DETECTED_IP=$(curl -sf https://api.ipify.org 2>/dev/null || echo "")
if [ -n "$DETECTED_IP" ]; then
  printf "${CYAN}Host${RESET} (domaine ou IP, défaut : ${BOLD}${DETECTED_IP}${RESET}) : "
else
  printf "${CYAN}Host${RESET} (domaine ou IP publique du VPS) : "
fi
read HOST_INPUT
APP_HOST=${HOST_INPUT:-$DETECTED_IP}

# Auto-détection du protocole
if echo "$APP_HOST" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
  APP_PROTOCOL=http
else
  APP_PROTOCOL=https
fi
echo "  → Protocole détecté : ${GREEN}${APP_PROTOCOL}${RESET}"

printf "${CYAN}Timezone${RESET} (défaut : Europe/Paris) : "
read TZ_INPUT
TZ=${TZ_INPUT:-Europe/Paris}

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
PORT=3310
TZ=${TZ}

# ── MongoDB ───────────────────────────────────────
MONGO_USER=${APP_NAME}
MONGO_PASS=${MONGO_PASS}
MONGO_DB_NAME=${APP_NAME}
MONGO_URL=mongodb://\${MONGO_USER}:\${MONGO_PASS}@mongo:27017/\${MONGO_DB_NAME}?authSource=admin

# ── Host ──────────────────────────────────────────
APP_HOST=${APP_HOST}
APP_PROTOCOL=${APP_PROTOCOL}

# ── CORS / URLs ───────────────────────────────────
CORS_ORIGIN=\${APP_PROTOCOL}://\${APP_HOST}
VITE_API_URL=\${APP_PROTOCOL}://\${APP_HOST}/api/

# ── JWT & Cookies ─────────────────────────────────
ACCESS_TOKEN_EXPIRATION_TIME=1h
ACCESS_TOKEN_SECRET=${ACCESS_TOKEN_SECRET}
REFRESH_TOKEN_SECRET=${REFRESH_TOKEN_SECRET}
COOKIE_SECRET=${COOKIE_SECRET}
EOF

echo ""
echo "${GREEN}✓ .env généré avec succès${RESET}"
echo ""
echo "  Projet   : ${BOLD}${APP_NAME}${RESET}"
echo "  Host     : ${BOLD}${APP_PROTOCOL}://${APP_HOST}${RESET}"
echo "  Timezone : ${BOLD}${TZ}${RESET}"
echo "  Secrets  : ${GREEN}générés automatiquement${RESET}"
echo ""
echo "Lance ${BOLD}make up${RESET} pour démarrer."
echo ""
