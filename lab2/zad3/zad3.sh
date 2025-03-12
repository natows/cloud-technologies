#!/bin/bash

NODE_VERSION=16


docker rm -f node_server3 database


DATABASE_ID=$(docker run -d --name database -p 27017:27017 -it mongo:4.4)
echo "Utworzono bazę o id $DATABASE_ID"


CONTAINER_ID=$(docker run -d -p 8080:8080 --name node_server3 -it node:$NODE_VERSION-alpine tail)
echo "Utworzono kontener o id $CONTAINER_ID"


cat <<EOF > package.json
{
  "name": "node-server",
  "version": "1.0.0",
  "description": "A simple Node.js app with MongoDB",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.17.1",
    "mongoose": "^5.11.18"
  },
  "author": "",
  "license": "ISC"
}
EOF
cat <<EOF > server.js
const express = require('express');
const mongoose = require('mongoose');

const app = express();
const port = 8080;

mongoose.connect('mongodb://host.docker.internal:27017/mydatabase', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open', () => console.log('Connected to MongoDB'));

const itemSchema = new mongoose.Schema({ name: String });
const Item = mongoose.model('Item', itemSchema);

app.use(express.json());

app.get('/', async (req, res) => {
  try {
    const items = await Item.find();
    res.status(200).json(items);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/add', async (req, res) => {
  try {
    const newItem = new Item({ name: req.body.name });
    await newItem.save();
    res.status(200).json({ message: 'Item added', item: newItem });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(\`Server running on http://localhost:\${port}/\`);
});
EOF


docker exec $CONTAINER_ID sh -c "mkdir -p /app"
echo "Utworzono folder /app w kontenerze"


docker cp server.js $CONTAINER_ID:/app/server.js
echo "Skopiowano plik server.js do kontenera"
docker cp package.json $CONTAINER_ID:/app/package.json
echo "Skopiowano plik package.json do kontenera"


docker exec $CONTAINER_ID sh -c "cd /app && npm install"


docker exec -d $CONTAINER_ID sh -c "cd /app && node server.js"
echo "Uruchomiono serwer"


#testy

sleep 5

response=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/add -H "Content-Type: application/json" -d '{"name": "testowy"}')

if [ "$response" -eq 200 ]; then
  echo "Dodano element do bazy"
else
  echo "Nie udało się dodać elementu do bazy"
fi

response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)

if [ "$response" -eq 200 ]; then
  echo "Pobrano elementy z bazy"
else
  echo "Nie udało się pobrać elementów z bazy"
fi
