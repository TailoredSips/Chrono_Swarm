# Chrono Swarm Deployment Guide

_This guide covers production deployment, environment configuration, and operational best practices._

## Prerequisites
- Rust toolchain
- Terraform
- Ansible
- Docker
- Cloud provider credentials

## Steps
1. **Provision Infrastructure:**
   ```sh
   cd terraform/environments/production
   terraform init && terraform apply
   ```
2. **Build Golden Images:**
   ```sh
   cd packer/golden-images
   packer build control-node.pkr.hcl
   packer build executor-node.pkr.hcl
   packer build bastion-node.pkr.hcl
   ```
3. **Run Ansible Playbooks:**
   ```sh
   ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml
   ```
4. **Deploy Services:**
   ```sh
   docker-compose -f deployment/docker/docker-compose.yml up -d
   ```

See [systemd/](../deployment/systemd/) for service management.
