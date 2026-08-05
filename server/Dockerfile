FROM debian:bookworm

RUN apt update && \
    apt install -y --no-install-recommends \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY build/ .

EXPOSE 8080

CMD ["./catjitsu-server.x86_64"]