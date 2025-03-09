
#!/bin/bash

version=14
port=8080

echo "const express = require('express');
const app = express();
const port = 8080;
app.get('/', (req, res) => {
  res.json({ date: new Date() });
});
app.listen(port, () => {
  console.log('Server running on http://localhost:' + port + '/');
});" > app/server.js

docker run -dit --name node_server2 -p $port:8080 node:$version-alpine
docker cp app/ node_server2:app/

docker exec -d node_server2 node app/server.js

#tests
sleep 5
response=$(curl -s http://localhost:8080)
echo "Odpowiedź z serwera: $response"

docker stop node_server2
docker rm node_server2


