FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
COPY . .
# It will look for routes.json, which we will mount
CMD ["node", "server.js"]
