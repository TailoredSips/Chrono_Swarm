const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const fs = require('fs');
const path = require('path');

const app = express();
const configPath = path.join(__dirname, 'routes.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

console.log('Orchestrator configuring routes...');
config.servers.forEach(server => {
  const { prefix, url } = server;
  console.log(`  -> Mapping prefix '/${prefix}' to target '${url}'`);
  app.use(`/mcp/${prefix}`, createProxyMiddleware({
    target: url,
    changeOrigin: true,
    pathRewrite: {
      [`^/mcp/${prefix}`]: '', // Rewrite path to remove prefix
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`[Orchestrator] Forwarding request for prefix '${prefix}' to ${url}${proxyReq.path}`);
    }
  }));
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`MCP Orchestrator alive and listening on port ${PORT}`);
});
