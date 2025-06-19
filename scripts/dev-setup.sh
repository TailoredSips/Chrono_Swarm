#!/bin/bash
# Chrono-Swarm - Proprietary Software
# Copyright (c) 2024 Chrono-Swarm Technologies. All rights reserved.

set -euo pipefail

echo "🚀 Setting up Chrono-Swarm development environment..."

# Install Rust components
rustup component add clippy rustfmt

# Create local config
mkdir -p ~/.chrono-swarm
echo "Development environment ready!"
