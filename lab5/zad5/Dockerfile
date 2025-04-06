FROM ubuntu:22.04 AS build

WORKDIR /app

RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSl https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY app/package*.json ./

RUN npm install

COPY app/ ./

FROM nginx:alpine

RUN mkdir -p /usr/share/nginx/html/app

COPY --from=build /app /usr/share/nginx/html

RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html index.htm; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]