#!/bin/bash
version=12
port=8080

echo "const http = require('http');
const port = 8080;
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World\n');
});
server.listen(port, () => {
  console.log('Server running on http://localhost:' + port + '/');
});" > server.js


docker run -dit --name node_server1 -p $port:8080 node:$version-alpine
docker cp server.js node_server1:/server.js
docker exec node_server1 node server.js


