# Chrono Swarm

Chrono Swarm is a distributed, event-driven orchestration platform for large-scale, intelligent, and resilient compute workloads. It leverages Rust, Terraform, Ansible, and modern cloud-native patterns to deliver high performance, reliability, and security.

## Quick Start

1. **Clone the repository:**
   ```sh
   git clone https://github.com/chrono-swarm/chrono_swarm.git
   cd chrono_swarm
   ```
2. **Build the workspace:**
   ```sh
   ./scripts/build.sh
   ```
3. **Deploy infrastructure:**
   ```sh
   cd terraform/environments/development
   terraform init && terraform apply
   ```
4. **Run Ansible playbooks:**
   ```sh
   ansible-playbook -i ansible/inventories/development ansible/playbooks/site.yml
   ```

See [docs/development.md](docs/development.md) for full setup instructions.

## Features
- Modular Rust microservices
- Intelligent scheduling and orchestration
- Secure agent sandboxing
- Event sourcing and streaming
- Automated disaster recovery
- Observability and monitoring

## License
MIT
