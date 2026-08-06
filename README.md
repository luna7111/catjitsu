*This project has been created as part of the 42 curriculum by acaro-su, acastrov, gtaza-ca, kde-la-c, ldel-val*

![image](catjitsu-client/assets/500x223.png)

## Description

Welcome to CatJitsu! A free-to-play card game where you can challenge your friends and beat your opponents by collection sets of winning CatJitsu cards!

The rules are very simple. Draw 5 cards from your deck, choose a CatJitsu card from your hand and defeat your rival in a hand-to-hand elemental combat! Fire, Water and Ice are your weapons in the dojo, so you have to master the elements in order to find the glory:

- Fire beats Snow
- Snow beats Water
- Water beats Fire

But remember, if two cards share the same element, only the card with the highesst number would stand in it's feet, or if the have the same points there will be a draw. Let the cats determine your destiniy!

## Instructions

To play CatJitsu,first you need to be able to deploy the neccesary files using Docker and Docker Compose. So first, make shure you are up tu date with Docker services. You can follow this [brief guide](https://dev.to/kingyou/complete-guide-installing-docker-and-docker-compose-step-by-step-24e1) or run the next command in your terminal

```
sudo apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install docker-compose-plugin
```

Once Docker and Docker Compose is installed, you can download the repo and run the Makefile that will take care of both build and deployment.

```
git clone https://github.com/luna7111/catjitsu.git
cd catjitsu
make
```

The make file will run the following commands in order:

- make export: calls a single Docker container (not part from the Docker Compose) to build and export the Godot files using Godot 4.7. The target files will be in client/web and server/build
- make build: will catch the local network IP and create the certificates for a secure https conection. Then will call to docker compose build and create the Docker images for the client and the server
- make up: docker compose up to keep the images and the microservices running

Once everything is running, you will see an output in the console which especifies in wich IP the game is being served.

```bash
[...]
CatJitsu is configured for:
https://<local_network_ip_address>:8443
Host IP: <local_network_ip_address>
[...]
```

Go to the `https://<local_network_ip_address>:8443` on a web browser of any device connected to your local network and have fun!

## Resources

### Frontend

### Godot
#### Documentation
- [Godot Docs](https://docs.godotengine.org/en/stable/#)

### WebSocket
#### Documentation
- [RFC 6455 - The WebSocket Protocol](https://datatracker.ietf.org/doc/html/rfc6455)
- [MDN - WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)

### AI USAGE
- Search of information relative to frontend and backend deployment and other tools used in this project (Godot, DJango...)
- Code review and refactoring in different stages of deployment
- Code generation in specific parts of deployment and WebSockets architecture


## Team Information

## Project Management

## Technical Stack

## Database Schema

## Features List

## Modules

## Individual Contributions

- acaro-su:

- acastrov: game development, gameplay, multiplayer, WebSockets

- gtaza-ca

- kde-la-c

- ldel-val
