#!/bin/bash

docker-compose up -d

sleep 5

docker exec -it db mongo --eval "db.stats()"
if [ $? -ne 0 ]; then
  echo "db error"
  exit 1
fi
echo "mongo ok"



response=$(curl -s http://localhost:3003)
if [[ "$response" != *"Server is running"* ]]; then
  echo "server error"
  exit 1
fi

echo "server ok"

#tworzenie kolekcji users i wyswietlanie jej
docker exec db mongo my_dbase --eval 'db.createCollection("users"); db.users.insertOne({"name": "user", "last_name": "kowalski"})'

docker exec db mongo my_dbase --quiet --eval "printjson(db.users.find().toArray())"

#pobieranie danych z bazy poprzez serwer 

response=$(curl http://localhost:3003/users)
echo "odpowiedz z serwera: $response"

docker-compose down -v --remove-orphans

