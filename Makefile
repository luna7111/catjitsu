COMPOSE = docker compose
BUILDER = catjitsu-builder

.PHONY: all cert export-web build up up-d down clean fclean re logs ps

all: up

cert:
	./client/scripts/generate-dev-cert.sh

export-web:
	docker build -t $(BUILDER) -f Dockerfile.builder .
	docker run --rm \
		-v "$(PWD)":/workspace \
		$(BUILDER)

build: cert export-web
	$(COMPOSE) build

up: build
	$(COMPOSE) up

up-d: build
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --remove-orphans --volumes
	docker builder prune -f
	rm -rf client/certs
	rm -rf client/web

fclean: clean
	docker system prune -f -a

re: clean up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps