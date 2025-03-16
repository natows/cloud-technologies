#!/bin/bash


update_page(){
    local html=$1
    echo "$html" > index.html
    docker cp index.html nginx_1:/usr/share/nginx/html/index.html
    rm index.html
}

CONTAINER_ID=$(docker run -d -p 8080:80 --name nginx_1 nginx)

HTML="<!DOCTYPE html>
<html>
<head>
    <titleKontener nginx</title>
</head>
<h1>Witaj w kontenerze nginx</h1>
</html>"

update_page "$HTML"

#test - sprawdzenie adresu strony
sleep 5
if curl localhost:8080;then
    echo "Strona działa poprawnie"
else
    echo "Strona nie działa poprawnie"
fi

#test - sprawdzenie zmiany zawartosci strony
HTML="<!DOCTYPE html>
<html>
<head>
    <titleKontener nginx</title>
</head>
<h1>Witaj w kontenerze nginx - zmiana</h1>
</html>"
update_page "$HTML"

sleep 5


if curl localhost:8080 | grep "Witaj w kontenerze nginx - zmiana";then
    echo "Strona została zmieniona"
else
    echo "Strona nie została zmieniona"
fi



docker rm -f nginx_1
