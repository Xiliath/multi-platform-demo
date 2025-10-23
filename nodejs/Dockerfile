FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .
COPY ../shared /shared

EXPOSE 5001

CMD ["npm", "start"]
