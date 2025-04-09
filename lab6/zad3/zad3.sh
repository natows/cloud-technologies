#!/bin/bash

docker network create  --driver bridge --subnet 192.168.100.0/24 --gateway 192.168.100.1 frontend_network
docker network create --internal --subnet 193.168.100.0/24 --gateway 193.168.100.1 backend_network


docker run -d \
  --name database \
  --network backend_network \
  --ip 193.168.100.2 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=appdb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=pass \
  mysql:8.0


sleep 10


docker run -d \
  --name backend \
  --network frontend_network \
  --ip 192.168.100.2 \
  -p 80:80 \
  python:3.9-slim sh -c "mkdir -p /app && while true; do sleep 1; done"


docker cp app.py backend:/app/
docker exec backend sh -c "pip install flask pymysql cryptography"
docker network connect backend_network backend
docker exec backend sh -c "apt-get update && apt-get install -y curl"
docker exec -d backend sh -c "cd /app && python app.py"



docker run -d \
  --name frontend \
  --ip 192.168.100.3 \
  --network frontend_network \
  nginx:alpine

docker exec frontend sh -c "apk add --no-cache curl"



sleep 5

echo "Testing backend -> database connection..."
docker exec backend sh -c "curl -s http://192.168.100.2/db" && echo "Backend połączony z bazą danych" || echo "Błąd połączenia backend -> database"

echo "Testing frontend -> backend connection..."
docker exec frontend sh -c "curl -s http://192.168.100.2:80" && echo "Frontend połączony z backendem" || echo "Błąd połączenia frontend -> backend"


docker rm -f backend frontend database
docker network rm frontend_network backend_network