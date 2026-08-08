# Remove sudo for 42 school pc

COMPOSE = docker compose
BUILDER = catjitsu-builder
NETWORK_NAME := catjitsu-network

.PHONY: all cert tos-pp export network build deploy deploy-d up up-d down clean fclean re logs ps

all: deploy

cert:
	./client/scripts/generate-dev-cert.sh

tos-pp:

export:
	docker build -t $(BUILDER) -f Dockerfile.builder .
	docker run --rm \
		-v "$(PWD)":/workspace \
		$(BUILDER)

network:
	@docker network inspect $(NETWORK_NAME) >/dev/null 2>&1 || \
		docker network create $(NETWORK_NAME)
	@echo "Docker network '$(NETWORK_NAME)' is ready."

build: cert
	$(COMPOSE) build
	$(COMPOSE) -f api/docker-compose.yml build

deploy: export build network
	docker compose -f api/docker-compose.yml up -d
	$(COMPOSE) up

deploy-d: export build network
	docker compose -f api/docker-compose.yml up -d
	$(COMPOSE) up -d

up: build network
	docker compose -f api/docker-compose.yml up -d
	$(COMPOSE) up

up-d: build network
	docker compose -f api/docker-compose.yml up -d
	$(COMPOSE) up -d

down:
	$(COMPOSE) down
	docker compose -f api/docker-compose.yml down

clean:
	$(COMPOSE) down --remove-orphans --volumes
	docker compose -f api/docker-compose.yml down --remove-orphans --volumes
	docker builder prune -f
	rm -rf client/certs
	rm -rf client/web
	rm -rf server/build

fclean: clean
	docker system prune -f -a

re: clean deploy

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps
	docker compose -f api/docker-compose.yml ps
