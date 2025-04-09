#!/bin/bash


docker network create --driver bridge --subnet=192.168.1.0/24 --gateway=192.168.1.1 my_bridge 
docker run -d --name my_container --network my_bridge alpine:latest sh -c "while true; do sleep 1; done"

response=$(docker exec my_container ping -c 1 192.168.1.1)
echo "$response"

check=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my_container)
echo "Container IP: $check"

docker rm -f my_container
docker network rm my_bridge