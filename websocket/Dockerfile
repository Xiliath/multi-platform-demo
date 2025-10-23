FROM node:22-alpine

WORKDIR /app

COPY websocket/package*.json ./
RUN npm install --production

COPY websocket/ .

EXPOSE 8081

CMD ["npm", "start"]
