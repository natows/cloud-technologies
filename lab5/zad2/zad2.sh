#!/bin/bash

cat <<EOF > Dockerfile
FROM node:latest
COPY app /app
WORKDIR /app
RUN npm install 
ENV NODE_ENV=production
CMD ["npm", "start"]
EOF

mkdir -p app
cat <<EOF > app/package.json
{
  "name": "my_node_app",
  "version": "1.0.0",
  "description": "A simple Node.js app",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {}
}
EOF

cat <<EOF > app/app.js
const http = require('http');

const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Witaj w Dockerze!\n');
});


server.listen(port, () => {
  console.log(\`serwer działa na porcie \${port}\`);
});
EOF

docker build -t my_node_app .
docker run --rm -p 3000:3000 my_node_app