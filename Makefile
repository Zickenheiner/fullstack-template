DEV  = docker compose -f docker-compose.dev.yml

# ─── Détection du mode de déploiement ─────────────────────────────────────────

DEPLOY_MODE := $(shell grep -s '^DEPLOY_MODE=' .env | cut -d= -f2 | tr -d '[:space:]')
PROXY_PATH  := $(shell grep -s '^PROXY_PATH=' .env | cut -d= -f2 | tr -d '[:space:]')
PROXY_PATH  := $(if $(PROXY_PATH),$(PROXY_PATH),../reverse-proxy)

ifeq ($(DEPLOY_MODE),domain)
  PROD = docker compose -f docker-compose.prod.domain.yml
else
  PROD = docker compose -f docker-compose.prod.yml
endif

# ─── Dev ──────────────────────────────────────────────────────────────────────

dev:
	$(DEV) up --build

dev-d:
	$(DEV) up --build -d

dev-down:
	$(DEV) down

dev-logs:
	$(DEV) logs -f

dev-logs-%:
	$(DEV) logs -f $*

dev-sh-%:
	$(DEV) exec $* sh

# ─── Prod ─────────────────────────────────────────────────────────────────────

up:
	$(PROD) up --build -d

down:
	$(PROD) down

restart:
	$(PROD) restart

logs:
	$(PROD) logs -f

logs-%:
	$(PROD) logs -f $*

sh-%:
	$(PROD) exec $* sh

# ─── Deploy ───────────────────────────────────────────────────────────────────

deploy:
	git pull
	$(PROD) up --build -d

# ─── DB ───────────────────────────────────────────────────────────────────────

mongo-sh:
	$(PROD) exec mongo mongosh -u $${MONGO_USER} -p $${MONGO_PASS} --authenticationDatabase admin

mongo-sh-dev:
	$(DEV) exec mongo mongosh -u $${MONGO_USER} -p $${MONGO_PASS} --authenticationDatabase admin

# ─── Setup ────────────────────────────────────────────────────────────────────

env:
	@sh setup.sh

.PHONY: dev dev-d dev-down dev-logs dev-sh-% \
        up down restart logs logs-% sh-% deploy \
        mongo-sh mongo-sh-dev env
