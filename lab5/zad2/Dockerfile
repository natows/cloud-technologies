FROM node:latest
COPY app /app
WORKDIR /app
RUN npm install 
ENV NODE_ENV=production
CMD ["npm", "start"]
