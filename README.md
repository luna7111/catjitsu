*This project has been created as part of the 42 curriculum by acaro-su, acastrov, gtaza-ca, kde-la-c, ldel-val*

<p align="center">
  <img src="catjitsu-client/assets/500x223.png" alt="Catjitsu logo">
</p>

## Description

Welcome to CatJitsu! A free-to-play card game where you can challenge your friends and beat your opponents by collection sets of winning CatJitsu cards!

The rules are very simple. Draw 5 cards from your deck, choose a CatJitsu card from your hand and defeat your rival in a hand-to-hand elemental combat! Fire, Water and Ice are your weapons in the dojo, so you have to master the elements in order to find the glory:

- Fire beats Snow
- Snow beats Water
- Water beats Fire

But remember, if two cards share the same element, only the card with the highesst number would stand in it's feet, or if the have the same points there will be a draw. Let the cats determine your destiniy!

Here are some of the key features of this project:
- Singleplayer card game using Godot open source game engine as framework
- Multiplayer card game with room code for individual lobbys using WebSockets and a Godot Linux Server
- Player avatar customization and settings
- ADD HERE-> BACKEND DATABASE MICROSERVICES

## Instructions

To play CatJitsu, first you need to be able to deploy the neccesary files on a Linux OS with an X86_64 architecture using Docker and Docker Compose. So first, make shure you are up tu date with Docker services. You can follow this [brief guide](https://dev.to/kingyou/complete-guide-installing-docker-and-docker-compose-step-by-step-24e1) or run the next command in your terminal

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

Go to the `https://<local_network_ip_address>:8443` on a web browser of any device connected to your local network (yeah, even smart phones) and have fun!

## Team Information
So, meet us! We are a small team of young programming students in [42 Telefonica](https://www.fundaciontelefonica.com/campus-42/):

- acaro-su [Developer]: Code review, Quality Assurance, frontend development

- acastrov [Project Manager, Developer]: Frontend and Multiplayer development, deployment architecture, music

- gtaza-ca [Developer]: Code review, Quality Assurance, backend development

- kde-la-c [Technical Lead]: Backend development, deployment architecture

- ldel-val [Product Owner, Developer]: Frontend and backend development, deployment architecture, graphics, art

## Project Management
In the first meetings we had, we decide to divide the work in two differently parts: 
- Frontend (Game Experience and multiplayer): the team in charge of making the game in Godot and ensure a multiplayer experience
- Backend (user data base, authentication, security): the team in charge to making a solid database and allow user registration and authentication via OATH

After our team was divided in two, we decided to use GitHub Issues to create issues and tickets for the different development stages of our product. We decide to usea a Git Flow workflow and create a new branch to every new feature of the game.

We also keep a continuis comunication using instant messages apps like Whatsapp or Slack, while keeping online meetings on Discord.

## Technical Stack

For the frontend, we decided to deploy a full featured multiplayer card game on web browsers. So we decided to use Godot, an oper source game engine. Not only it contais the neccesary tools to build a 2D card game from the ground up, it also contains a High Level Network API for easy multiplayer features. Speaking of multiplayer, we decided to use WebSockets as the comunication protocol for the multiplayer server, also developed in Godot.

ADD HERE -> BACKEND DEVELOPMENT

## Database Schema

ADD HERE -> DATABASE SCHEMA

## Features List

- Full singleplayer experience: battle against an opponent AI
- Full multiplayer experience: challenge your friends on a Catjitsu game
- Code Room lobbys: a quick system to easily find your rivals on the same net
- Avatar customization: full 3D models for some of the cutest cats on earth!
- Multiple language support: choose to experience your game on english, spanish or french
- Accesibility options: screen reader support, keyboard navigation and assistive technologies
- Multiple control support: play your cards with mouse, keyboard or a controller

ADD HERE -> BACKEND FEATURES

## Modules
### Web
#### Major
- Use a framework for both the frontend and backend: Use of a frontend and networking framework (Godot) and backend framework (DJango)[acaro-su, acastrov, gtaza-ca, kde-la-c, ldel-val] ADD HERE -> Lets talk about this one
- Implement real-time features using WebSockets or similar technology [acaro-su, acastrov]: deployment of WebSockets in the server thanks to Godot High Level Network API
- A public API to interact with the database with a secured API key, rate limiting, documentation, and at least 5 endpoints[gtaza-ca, kde-la-c, ldel-val]: ADD HERE -> API
#### Minor
- Custom-made design system with reusable components, including a proper color palette, typography, and icons (minimum: 10 reusable components)[ldel-val]: ADD HERE -> GODOT CUSTOM THEMES

### Accesibility and Internationalization
#### Major
- Complete accessibility compliance (WCAG 2.1 AA) with screen reader support, keyboard navigation, and assistive technologies[ldel-val, gtaza-ca]: screen reader support, keyboard and controller integration, use of OpenDyslexic font.
#### Minor
- Support for multiple languages (at least 3 languages)[gtaza-ca, kde-la-c, ldel-val]: support for english, french and spanish with il8n integration
- Support for additional browsers[acastrov, ldel-val]: compatibility with Google Chrome, Firefox and Safari

### User Management
#### Minor
- Implement remote authentication with OAuth 2.0 (Google, GitHub, 42, etc.)[gtaza-ca, kde-la-c, ldel-val]: ADD HERE -> OATH 42 implementation

### Artificial Intelligence
#### Major
- Introduce an AI Opponent for games[acastrov, ldel-val]: ADD HERE -> Will see, will see >:")

### Gaming and user experience
#### Major
- Implement a complete web-based game where users can play against each other[acaro-su, acastrov, ldel-val]: full multiplayer experience through Godot frontend and High Level Network API using WebSockets
- Remote players — Enable two players on separate computers to play the same game in real-time [acaro-su, acastrov]: multiplayer lobby system across multiple computers in the same local network
- Implement advanced 3D graphics using a library like Three.js or Babylon.js[ldel-val]: ADD HERE -> Tell them about them cats!

### Point calculation
Major modules: 9 (18 points)
Minor modules: 4 (4 points)
Total: 22 points

## Individual Contributions

- acaro-su: ADD HERE

- acastrov: game development, gameplay, multiplayer, WebSockets

- gtaza-ca: ADD HERE

- kde-la-c: ADD HERE

- ldel-val: ADD HERE

## Resources

### Frontend
#### Godot
##### Documentation
- [Godot Docs](https://docs.godotengine.org/en/stable/#)
- [Exporting for the Web - Godot Docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
  
##### Tutorials
- [Card Game Godot 4.3 COMPLETE TUTORIAL - Barry's Dev Hell (playlist)](https://www.youtube.com/playlist?list=PLNWIwxsLZ-LMYzxHlVb7v5Xo5KaUV7Tq1)
- [Dedicated Multiplayer - Game Development Center (playlist)](https://www.youtube.com/playlist?list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s)

##### Videos
- [Godot Multiplayer Tutorial: The Quick and Easy High-Level API - IcyEngine](https://www.youtube.com/watch?v=YnfsyZJRsL8)

### Backend
#### WebSocket
##### Articles
- [WebSocket and Its Difference from HTTP](https://www.geeksforgeeks.org/web-tech/what-is-web-socket-and-how-it-is-different-from-the-http/)
- [WebSocket Explained: What It Is and How It WorksWebSocket Explained: What It Is and How It Works](https://medium.com/@omargoher/websocket-explained-what-it-is-and-how-it-works-b9eafefe28d7)
##### Documentation
- [RFC 6455 - The WebSocket Protocol](https://datatracker.ietf.org/doc/html/rfc6455)
- [MDN - WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
- [Godot Docs - Using WebSockets](https://docs.godotengine.org/en/stable/tutorials/networking/websocket.html)
##### Videos
- [Godot High Level Multiplayer and WebSockets connection - Davies dev](https://www.youtube.com/watch?v=RQKodnluOp8&list=PLylNHWOqRhsGCmeOcKOPnbMRKSNqqQycM)

ADD HERE -> Rest of backend documentation

### AI USAGE
We tried to keep AI usage usage at a minimun to sharpen our skill and critical thinking, but we also understand that is a tool that, if used correctly, can accelerate production times. We tried to strike a balance bewteen the implementation of this tool an it's ethical use, keeping in mind how it's abuse can impact (water compsumption)[https://www.forbes.com/sites/robertszczerba/2026/07/21/how-much-water-does-ai-use-the-58-billion-risk/] and how detrimental can be to [artist](https://news.un.org/en/story/2026/02/1166989), while the possible [copyright infrigment](https://www.forbes.com/sites/virginieberger/2025/03/15/the-ai-copyright-battle-why-openai-and-google-are-pushing-for-fair-use/) are still being studied.

So, we decided to keep AI usage only to code and documentation tasks, such as:

- Search of information relative to frontend and backend deployment and other tools used in this project (Godot, DJango...)
- Code review and refactoring in different stages of deployment
- Code generation in specific parts of deployment and WebSockets architecture
- English spelling and grammar

None of the art nor the music has used AI in any way. 