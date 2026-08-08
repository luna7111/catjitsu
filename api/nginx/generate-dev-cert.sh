#!/usr/bin/env bash

set -e

CERT_DIR="./api/nginx/certs"

mkdir -p "$CERT_DIR"

# IP="127.0.0.1"
IP=$(hostname -I | awk '{print $1}')

echo "Generating development certificate for $IP"

cat > /tmp/catjitsu-openssl.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[dn]
CN = $IP

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = $IP
EOF

openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout "$CERT_DIR/server.key" \
    -out "$CERT_DIR/server.crt" \
    -config /tmp/catjitsu-openssl.cnf

rm /tmp/catjitsu-openssl.cnf

echo
echo "Certificate created:"
echo "  $CERT_DIR/server.crt"
echo "  $CERT_DIR/server.key"
echo "CatJitsu is configured for:"
echo "https://$IP:8001"
echo "Host IP: $IP"