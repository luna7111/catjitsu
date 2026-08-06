FROM debian:bookworm

RUN apt update && \
    apt install -y nginx && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html/*

COPY web/ /var/www/html/
COPY nginx.conf /etc/nginx/nginx.conf
COPY certs/ /etc/nginx/certs/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]