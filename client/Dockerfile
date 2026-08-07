FROM debian:bookworm

RUN apt update && \
    apt install -y nginx && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html/*

COPY web/ /var/www/html/web/
COPY wrapper/ /var/www/html/
COPY tos/ /var/www/html/tos/
COPY privacy/ /var/www/html/privacy/
COPY nginx.conf /etc/nginx/nginx.conf
COPY certs/ /etc/nginx/certs/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
