FROM node:22-alpine

WORKDIR /app

COPY nodejs/package*.json ./
RUN npm install --production

COPY nodejs/ .
COPY shared /shared

EXPOSE 5001

CMD ["npm", "start"]
