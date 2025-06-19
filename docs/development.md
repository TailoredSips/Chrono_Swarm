# Chrono Swarm Development Guide

_This guide describes how to set up a local development environment._

## Prerequisites
- Rust toolchain
- Docker
- Terraform
- Ansible

## Setup
1. **Clone the repository:**
   ```sh
   git clone https://github.com/chrono-swarm/chrono_swarm.git
   cd chrono_swarm
   ```
2. **Install dependencies:**
   ```sh
   ./scripts/dev-setup.sh
   ```
3. **Start local infrastructure:**
   ```sh
   cd terraform/environments/development
   terraform init && terraform apply
   ```
4. **Run Ansible playbooks:**
   ```sh
   ansible-playbook -i ansible/inventories/development ansible/playbooks/site.yml
   ```

See [development.md](development.md) for more.
