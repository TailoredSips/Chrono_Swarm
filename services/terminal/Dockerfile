FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
# HUGE SECURITY WARNING: THIS IS A DANGEROUS ENDPOINT.
# It executes arbitrary code from the LLM. ONLY use this inside the
# trusted, isolated environment of GitHub Codespaces.
# The 'E2B' sandbox is the production-safe way to do this.
CMD ["node", "server.js"]
