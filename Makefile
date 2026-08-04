# Remove sudo for 42 school pc
COMPOSE = sudo docker compose

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
	sudo docker image rm -f catjitsu-client catjitsu-server 2>/dev/null || true
	sudo docker builder prune -f
	rm -r client/certs

fclean: clean
	sudo docker system prune -f

re: clean build up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps