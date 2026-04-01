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

# ── Détection du mode de déploiement ──────────────────────────────────────────

if echo "$APP_HOST" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
  # IP détectée → mode port
  APP_PROTOCOL=http
  DEPLOY_MODE=port
  echo "  → Mode détecté : ${GREEN}port${RESET} (IP — HTTP uniquement)"

  printf "${CYAN}Port d'écoute${RESET} (défaut : ${BOLD}8080${RESET}) : "
  read PORT_INPUT
  APP_PORT=${PORT_INPUT:-8080}
  echo "  → Port : ${GREEN}${APP_PORT}${RESET}"

  PROXY_PATH=""
else
  # Domaine détecté → mode domain
  APP_PROTOCOL=https
  DEPLOY_MODE=domain
  echo "  → Mode détecté : ${GREEN}domain${RESET} (HTTPS automatique via Let's Encrypt)"

  APP_PORT=""

  printf "${CYAN}Chemin vers le reverse-proxy${RESET} (défaut : ${BOLD}../reverse-proxy${RESET}) : "
  read PROXY_INPUT
  PROXY_PATH=${PROXY_INPUT:-../reverse-proxy}
fi

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

if [ "$DEPLOY_MODE" = "domain" ]; then
  cat > .env <<EOF
# ── Application ───────────────────────────────────
PORT=3310
TZ=${TZ}

# ── MongoDB ───────────────────────────────────────
MONGO_USER=${APP_NAME}
MONGO_PASS=${MONGO_PASS}
MONGO_DB_NAME=${APP_NAME}
MONGO_URL=mongodb://\${MONGO_USER}:\${MONGO_PASS}@mongo:27017/\${MONGO_DB_NAME}?authSource=admin

# ── Déploiement ───────────────────────────────────
DEPLOY_MODE=domain
COMPOSE_PROJECT_NAME=${APP_NAME}
PROXY_PATH=${PROXY_PATH}

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
else
  cat > .env <<EOF
# ── Application ───────────────────────────────────
PORT=3310
TZ=${TZ}

# ── MongoDB ───────────────────────────────────────
MONGO_USER=${APP_NAME}
MONGO_PASS=${MONGO_PASS}
MONGO_DB_NAME=${APP_NAME}
MONGO_URL=mongodb://\${MONGO_USER}:\${MONGO_PASS}@mongo:27017/\${MONGO_DB_NAME}?authSource=admin

# ── Déploiement ───────────────────────────────────
DEPLOY_MODE=port
APP_PORT=${APP_PORT}

# ── Host ──────────────────────────────────────────
APP_HOST=${APP_HOST}
APP_PROTOCOL=${APP_PROTOCOL}

# ── CORS / URLs ───────────────────────────────────
CORS_ORIGIN=\${APP_PROTOCOL}://\${APP_HOST}:\${APP_PORT}
VITE_API_URL=\${APP_PROTOCOL}://\${APP_HOST}:\${APP_PORT}/api/

# ── JWT & Cookies ─────────────────────────────────
ACCESS_TOKEN_EXPIRATION_TIME=1h
ACCESS_TOKEN_SECRET=${ACCESS_TOKEN_SECRET}
REFRESH_TOKEN_SECRET=${REFRESH_TOKEN_SECRET}
COOKIE_SECRET=${COOKIE_SECRET}
EOF
fi

echo ""
echo "${GREEN}✓ .env généré avec succès${RESET}"

# ── Mode domain : génération du fichier .caddy ────────────────────────────────

if [ "$DEPLOY_MODE" = "domain" ]; then
  CADDY_FILE="${APP_NAME}.caddy"

  cat > "$CADDY_FILE" <<EOF
${APP_HOST} {
    handle /api/* {
        uri strip_prefix /api
        reverse_proxy ${APP_NAME}-backend-1:3310
    }
    handle {
        reverse_proxy ${APP_NAME}-frontend-1:80
    }
}
EOF

  echo "${GREEN}✓ ${CADDY_FILE} généré${RESET}"

  # Copie vers le reverse-proxy si le dossier existe
  if [ -d "$PROXY_PATH/conf.d" ]; then
    cp "$CADDY_FILE" "$PROXY_PATH/conf.d/$CADDY_FILE"
    echo "${GREEN}✓ Config copiée vers ${PROXY_PATH}/conf.d/${RESET}"

    # Reload Caddy si le stack reverse-proxy tourne
    if docker compose -f "$PROXY_PATH/docker-compose.yml" ps --quiet caddy 2>/dev/null | grep -q .; then
      docker compose -f "$PROXY_PATH/docker-compose.yml" exec caddy caddy reload --config /etc/caddy/Caddyfile
      echo "${GREEN}✓ Caddy rechargé${RESET}"
    else
      echo "${YELLOW}⚠ Le reverse-proxy ne tourne pas encore.${RESET}"
      echo "  Lance-le avec : cd ${PROXY_PATH} && make up"
    fi
  else
    echo "${YELLOW}⚠ Dossier reverse-proxy introuvable (${PROXY_PATH}).${RESET}"
    echo "  Copie manuelle requise : cp ${CADDY_FILE} ${PROXY_PATH}/conf.d/"
    echo "  Puis : cd ${PROXY_PATH} && make up (ou make reload si déjà lancé)"
  fi
fi

# ── Résumé ────────────────────────────────────────────────────────────────────

echo ""
echo "  Projet   : ${BOLD}${APP_NAME}${RESET}"
if [ "$DEPLOY_MODE" = "domain" ]; then
  echo "  URL      : ${BOLD}${APP_PROTOCOL}://${APP_HOST}${RESET}"
  echo "  Mode     : ${BOLD}domain${RESET} (HTTPS via Let's Encrypt)"
else
  echo "  URL      : ${BOLD}${APP_PROTOCOL}://${APP_HOST}:${APP_PORT}${RESET}"
  echo "  Mode     : ${BOLD}port${RESET} (HTTP)"
fi
echo "  Timezone : ${BOLD}${TZ}${RESET}"
echo "  Secrets  : ${GREEN}générés automatiquement${RESET}"
echo ""
echo "Lance ${BOLD}make up${RESET} pour démarrer."
echo ""
