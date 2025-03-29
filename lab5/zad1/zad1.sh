#!/bin/bash

cat <<EOF > Dockerfile
FROM alpine:latest
CMD ["echo", "Witaj w Dockerze!"]
EOF

docker build -t my_alpine_image .
docker run --rm my_alpine_image
