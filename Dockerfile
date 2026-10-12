FROM node:18-alpine

WORKDIR /app

ENV PORT=3000

COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

EXPOSE 3000

CMD ["node", "server.js"]
