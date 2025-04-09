#!/bin/bash

docker network create --driver bridge my_network

docker run -d --name web --network my_network -p 3000:3000 node sh -c "while true; do sleep 1; done"
docker run -d \
  --name db \
  --network my_network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=userpass \
  -v $(pwd)/base/init.sql:/docker-entrypoint-initdb.d/init.sql \
  mysql:8.0

docker cp node-app/. web:/app
docker exec web sh -c "cd /app && npm install"
docker exec web sh -c "cd /app && npm start"