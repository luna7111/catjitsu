# Remove sudo for 42 school pc
HOST_IP := $(shell hostname -I | awk '{print $$1}')
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

build: cert
	HOST_IP=$(HOST_IP) $(COMPOSE) build

deploy: export build
	HOST_IP=$(HOST_IP) $(COMPOSE) up

deploy-d: export build
	HOST_IP=$(HOST_IP) $(COMPOSE) up -d

up: build
	HOST_IP=$(HOST_IP) $(COMPOSE) up

up-d: build
	HOST_IP=$(HOST_IP) $(COMPOSE) up -d

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
