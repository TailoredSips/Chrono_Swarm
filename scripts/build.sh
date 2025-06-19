#!/bin/bash
# Chrono-Swarm - Proprietary Software
# Copyright (c) 2024 Chrono-Swarm Technologies. All rights reserved.

set -euo pipefail

echo "🔨 Building Chrono-Swarm..."
cargo build --workspace
echo "✅ Build completed successfully"
