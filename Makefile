DEV  = docker compose -f docker-compose.dev.yml
PROD = docker compose -f docker-compose.prod.yml

# ─── Dev ──────────────────────────────────────────────────────────────────────

dev-up:
	$(DEV) up --build -d
	@$(MAKE) --no-print-directory dev-compass

dev-port:
	@for i in $$(seq 1 30); do \
	  PORT=$$($(DEV) port mongo 27017 2>/dev/null | cut -d: -f2); \
	  [ -n "$$PORT" ] && echo $$PORT && exit 0; \
	  sleep 0.2; \
	done; \
	echo "Timeout : port mongo introuvable" >&2; exit 1

dev-compass:
	@PORT=$$($(MAKE) --no-print-directory dev-port); \
	MONGO_USER=$$(grep '^MONGO_USER=' .env | cut -d= -f2); \
	MONGO_PASS=$$(grep '^MONGO_PASS=' .env | cut -d= -f2); \
	MONGO_DB=$$(grep '^MONGO_DB_NAME=' .env | cut -d= -f2); \
	echo ""; \
	echo "Compass : mongodb://$$MONGO_USER:$$MONGO_PASS@localhost:$$PORT/$$MONGO_DB?authSource=admin"

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

dev-setup:
	@sh setup.dev.sh

setup:
	@sh setup.prod.sh

.PHONY: dev-up dev-port dev-compass dev-down dev-logs dev-sh-% \
        up down restart logs logs-% sh-% deploy \
        mongo-sh mongo-sh-dev dev-setup
