ENV_FILE ?= .env
REALM_TEMPLATE := keycloak/realm-maphub.template.json
REALM_GENERATED := keycloak/realm-maphub.generated.json

# Export all variables from .env into the environment for envsubst
ifneq (,$(wildcard $(ENV_FILE)))
include $(ENV_FILE)
export $(shell sed -n 's/=.*//p' $(ENV_FILE))
endif

# Choose container engine (prefers podman if available)
COMPOSE ?= docker compose
ifneq ($(shell command -v podman >/dev/null 2>&1 && echo yes || echo no),no)
COMPOSE := podman compose
endif

.PHONY: prepare up down logs ps clean config

prepare:
	@mkdir -p keycloak
	@echo "Generating Keycloak realm from template..."
	@envsubst < $(REALM_TEMPLATE) > $(REALM_GENERATED)
	@echo "Generated: $(REALM_GENERATED)"

up: prepare
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f --tail=200

ps:
	$(COMPOSE) ps

config:
	$(COMPOSE) config

clean: down
	rm -f $(REALM_GENERATED)
