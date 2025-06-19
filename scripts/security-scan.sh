#!/bin/bash
# Security vulnerability scanning
set -e
cargo audit || true
trivy fs . || true
terraform validate || true
ansible-lint ansible/playbooks/ || true
