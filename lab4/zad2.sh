#!/bin/bash

docker volume create nodejs_data

docker run -d \
  --name nodejs_container \
  -v nodejs_data:/app \
  node:latest \
  sleep infinity 


cat << EOF > temp_app.js
console.log("Hello from Node.js!");
EOF

docker cp temp_app.js nodejs_container:/app/app.js


docker volume create all_volumes


docker run --rm \
  -v nginx_data:/nginx_data \
  -v nodejs_data:/nodejs_data \
  -v all_volumes:/all_volumes \
  busybox:latest \
  sh -c "mkdir -p /all_volumes/nginx && mkdir -p /all_volumes/nodejs && cp -r /nginx_data/* /all_volumes/nginx/ && cp -r /nodejs_data/* /all_volumes/nodejs/"


rm temp_app.js

echo "Zawartość woluminu all_volumes:"
docker run --rm \
  -v all_volumes:/all_volumes \
  busybox:latest \
  ls -R /all_volumes