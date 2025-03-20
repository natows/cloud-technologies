#!/bin/bash

NETWORK_NAME="my_network"
NODE_APP_CONTAINER="my-node-app"
NGINX_CONTAINER="my-nginx-container"
NODE_PORT=3000
NGINX_PORT=80
NGINX_SSL_PORT=443

# Usuń istniejące kontenery, jeśli istnieją
docker rm -f $NODE_APP_CONTAINER $NGINX_CONTAINER || true

# Utwórz sieć Docker, jeśli nie istnieje
if ! docker network ls | grep -q $NETWORK_NAME; then
  echo "Tworzenie sieci Docker: $NETWORK_NAME"
  docker network create $NETWORK_NAME
fi

# Przygotuj aplikację Node.js
mkdir -p app
cat <<EOF > app/server.js
const http = require('http');
const server = http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello from Node.js!\n');
});
server.listen(3000, () => console.log('Server running on port 3000'));
EOF
cat <<EOF > app/package.json
{
  "name": "node-app",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  }
}
EOF

# Konfiguracja Nginx
cat <<EOF > nginx.conf
worker_processes auto;
events {}

http {
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m inactive=60m;
    proxy_cache_key "\$scheme\$proxy_host\$request_uri";

    server {
        listen 80;
        listen 443 ssl;
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://$NODE_APP_CONTAINER:3000;
            proxy_cache my_cache;
            proxy_cache_valid 200 10m;
        }
    }
}
EOF

# Uruchom kontener Node.js
echo "Uruchamianie kontenera Node.js..."
NODE_CONTAINER_ID=$(docker run -d --network $NETWORK_NAME --name $NODE_APP_CONTAINER node:14 sh -c "sleep infinity")
docker exec $NODE_CONTAINER_ID bash -c "mkdir -p /app"
docker cp app/. $NODE_CONTAINER_ID:/app
docker exec $NODE_CONTAINER_ID sh -c "cd app && npm install"
docker exec -d $NODE_CONTAINER_ID sh -c "cd app && node server.js"

# Uruchom kontener Nginx
echo "Uruchamianie kontenera Nginx..."
NGINX_CONTAINER_ID=$(docker run -d --name $NGINX_CONTAINER --network $NETWORK_NAME -p $NGINX_PORT:80 -p $NGINX_SSL_PORT:443 nginx)

# Generowanie certyfikatów w kontenerze Nginx
echo "Generowanie certyfikatów w kontenerze Nginx..."
docker exec $NGINX_CONTAINER_ID sh -c "apt-get update && apt-get install -y openssl && \
  mkdir -p /etc/nginx/ssl && \
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/key.pem -out /etc/nginx/ssl/cert.pem -subj '/CN=localhost'"

# Sprawdzenie, czy certyfikaty zostały wygenerowane
docker exec $NGINX_CONTAINER_ID sh -c "ls /etc/nginx/ssl/cert.pem >/dev/null 2>&1"
if [ $? -eq 0 ]; then
  echo "Certyfikaty SSL zostały pomyślnie wygenerowane."
else
  echo "Błąd: Nie udało się wygenerować certyfikatów SSL."
  exit 1
fi

# Kopiowanie konfiguracji i restart Nginx
echo "Kopiowanie konfiguracji Nginx..."
docker cp nginx.conf $NGINX_CONTAINER_ID:/etc/nginx/nginx.conf
docker exec $NGINX_CONTAINER_ID nginx -s reload

# Test 1: Sprawdzenie konfiguracji Nginx
echo "TEST 1: Sprawdzenie konfiguracji Nginx"
if docker exec $NGINX_CONTAINER_ID nginx -t >/dev/null 2>&1; then
  echo "Konfiguracja Nginx jest poprawna."
else
  echo "Konfiguracja Nginx jest niepoprawna."
  exit 1
fi

# Test 2: Sprawdzenie, czy Node.js nasłuchuje na porcie 3000
echo "TEST 2: Sprawdzenie działania Node.js"
docker exec $NODE_CONTAINER_ID sh -c "apt-get update && apt-get install -y net-tools"
if docker exec $NODE_CONTAINER_ID sh -c "netstat -tuln | grep :3000" >/dev/null 2>&1; then
  echo "Node.js nasłuchuje na porcie 3000."
else
  echo "Błąd: Node.js nie nasłuchuje na porcie 3000."
  exit 1
fi

# Test 3: Sprawdzenie odpowiedzi HTTP z Nginx (port 80)
echo "TEST 3: Sprawdzenie odpowiedzi HTTP na porcie 80"
if curl -s http://localhost:$NGINX_PORT | grep -q "Hello from Node.js!"; then
  echo "Nginx poprawnie odpowiada na HTTP (port 80)."
else
  echo "Błąd: Nginx nie odpowiada poprawnie na HTTP (port 80)."
  exit 1
fi

# Test 4: Sprawdzenie odpowiedzi HTTPS z Nginx (port 443)
echo "TEST 4: Sprawdzenie odpowiedzi HTTPS na porcie 443"
if curl -s -k https://localhost:$NGINX_SSL_PORT | grep -q "Hello from Node.js!"; then
  echo "Nginx poprawnie odpowiada na HTTPS (port 443)."
else
  echo "Błąd: Nginx nie odpowiada poprawnie na HTTPS (port 443)."
  exit 1
fi

echo "Wszytskie testy zakończone pomyślnie."