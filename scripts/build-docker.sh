#!/bin/bash
set -e

SERVICE=${1:-cs-orchestrator}
echo "Building Docker image for $SERVICE..."

# Check if service-specific Dockerfile exists
if [ -f "deployment/docker/service-dockerfiles/Dockerfile.$SERVICE" ]; then
    DOCKERFILE="deployment/docker/service-dockerfiles/Dockerfile.$SERVICE"
else
    DOCKERFILE="deployment/docker/Dockerfile.multi-stage"
fi

docker build -f $DOCKERFILE -t $SERVICE:latest .
echo "Successfully built $SERVICE:latest"
