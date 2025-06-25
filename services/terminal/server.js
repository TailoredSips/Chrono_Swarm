const express = require('express');
const { exec } = require('child_process');
const app = express();
app.use(express.json());

// HUGE SECURITY WARNING: THIS IS A DANGEROUS ENDPOINT.
// It executes arbitrary code from the LLM. ONLY use this inside the
// trusted, isolated environment of GitHub Codespaces.
// The 'E2B' sandbox is the production-safe way to do this.

app.post('/tool/execute', (req, res) => {
    const command = req.body.tool_code;
    if (!command) {
        return res.status(400).send({ error: 'No tool_code provided' });
    }

    console.log(`[Terminal Agent] Executing command: ${command}`);

    // Execute from the /workspaces directory for context
    exec(command, { cwd: '/workspaces' }, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            return res.status(500).send({
                stdout: stdout,
                stderr: `EXECUTION FAILED: ${stderr}`,
                error: error.message,
            });
        }
        res.send({ stdout: stdout, stderr: stderr });
    });
});

const PORT = 8080;
app.listen(PORT, console.log(`Lean Terminal Agent listening on ${PORT}`));
