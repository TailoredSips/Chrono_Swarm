FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
# This server is special; it doesn't have a main .js file, so we use npx
CMD ["npx", "@modelcontextprotocol/server-filesystem", "/workspace"]
