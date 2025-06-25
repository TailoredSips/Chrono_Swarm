# Use a lightweight base image, e.g., node-slim for a TypeScript server
FROM node:20-slim

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy the server's source code
COPY . .

# Expose the port the MCP server will listen on (if it's HTTP-based)
# Let's assume it uses port 8080
EXPOSE 8080

# The command to start the server when the container runs
CMD [ "node", "server.js" ]
