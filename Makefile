# Remove sudo for 42 school pc
COMPOSE = docker compose

.PHONY: all cert build up up-d down clean fclean re logs ps

all: up

cert:
	./client/scripts/generate-dev-cert.sh

build: cert
	$(COMPOSE) build

up: cert
	$(COMPOSE) up

up-d: cert
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --remove-orphans --volumes
	docker builder prune -f
	rm -r client/certs

fclean: clean
	docker system prune -f -a

re: clean build up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps