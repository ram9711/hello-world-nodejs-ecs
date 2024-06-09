# Base image
FROM node:14

WORKDIR /app

COPY . .

EXPOSE 80

CMD ["node", "server.js"]
