#!/bin/bash
# Chrono-Swarm - Proprietary Software
# Copyright (c) 2024 Chrono-Swarm Technologies. All rights reserved.

set -euo pipefail

echo "🧪 Running test suite..."
cargo test --workspace
echo "✅ All tests passed"
