#!/bin/bash
# System health validation
set -e
curl -f http://localhost:8080/health || exit 1
echo "System health check passed."
