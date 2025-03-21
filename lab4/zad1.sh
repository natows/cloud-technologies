#!/bin/bash

docker volume create nginx_data

docker run -d \
  --name nginx_container \
  -v nginx_data:/usr/share/nginx/html \
  -p 8080:80 \
  nginx:latest

cat << EOF > temp_index.html
<!DOCTYPE html>
<html>
<head>
    <title>Nowa strona Nginx</title>
</head>
<body>
    <h1>zmodyfikowana strona</h1>
</body>
</html>
EOF

docker cp temp_index.html nginx_container:/usr/share/nginx/html/index.html

rm temp_index.html

rm -f nginx_container