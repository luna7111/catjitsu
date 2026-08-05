FROM debian:bookworm

RUN apt update && \
    apt install -y --no-install-recommends \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY build/ .
COPY docker-entrypoint.sh .

RUN chmod +x docker-entrypoint.sh

EXPOSE 8080

CMD ["./catjitsu-server.x86_64"]