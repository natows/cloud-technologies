twórz skrypt w powłoce BASH, który stworzy kontener Docker z wersją Node.js 14 i aplikacją Express.js, która obsłuży żądania HTTP na porcie 8080 i zwróci odpowiedź JSON z obecną datą i godziną.

Umieść również testy, sprawdzające poprawność powyższego skryptu.
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
});" > server.js

docker run -dit --name node_server2 -p $port:8080 node:$version-alpine
docker cp server.js node_server2:/server.js
docker exec node_server2 node server.js

