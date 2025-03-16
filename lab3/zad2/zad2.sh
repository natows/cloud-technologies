#!/bin/bash


docker run -d -p 8080:80 --name nginx_2 nginx

#test - czy kontener dziala na domyslnych ustawieniach
curl localhost:8080
if [ $? -eq 0 ]; then
    echo "Nginx działa na porcie 8080"
else
    echo "Nginx nie działa na poarcie 8080"
    exit 1
fi


sleep 3

read -p "Czy chcesz ustawić nowy plik konfiguracyjny? (t/n): " DECISION
if [ "$DECISION" == "t" ]; then
    read -p "na jakim porcie ma działać Nginx (inny niz 8080): " PORT
    sed -i "s/listen [0-9]\+;/listen $PORT;/" custom_nginx.conf

    

    docker rm -f nginx_2
    docker run -d -p $PORT:80 --name nginx_2 nginx
    sleep 3
    docker cp custom_nginx.conf nginx_2:/etc/nginx/conf.d/default.conf
    docker exec nginx_2 nginx -s reload
    echo "Nginx działa na porcie $PORT"

    sleep 3

    #test - sprawdzenie czy strona działa na nowym porcie
    if curl localhost:$PORT;then
        echo "Strona działa poprawnie"
    else
        echo "Strona nie działa poprawnie"
    fi
fi


docker rm -f nginx_2

