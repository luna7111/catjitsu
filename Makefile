# Remove sudo for 42 school pc
COMPOSE = docker compose
BUILDER = catjitsu-builder

.PHONY: all cert export build deploy up up-d down clean fclean re logs ps tos-pp

all: deploy

cert:
	./client/scripts/generate-dev-cert.sh
	./api/nginx/generate-dev-cert.sh

tos-pp:

export:
	docker build -t $(BUILDER) -f Dockerfile.builder .
	docker run --rm \
		-v "$(PWD)":/workspace \
		$(BUILDER)
	./scripts/copy-docs.sh

build: cert
	$(COMPOSE) build

deploy: export build
	$(COMPOSE) up

deploy-d: export build
	$(COMPOSE) up -d

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
	rm -rf server/build

fclean: clean
	docker system prune -f -a

re: clean deploy

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps