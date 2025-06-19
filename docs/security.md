# Chrono Swarm Security Model

_This document details the security architecture, controls, and hardening procedures._

## Principles
- Least privilege
- Defense in depth
- Secure by default

## Controls
- All secrets managed in a secure vault
- Network segmentation and firewalls
- Automated vulnerability scanning
- Agent sandboxing and resource limits

## Hardening
- OS and package hardening via Packer and Ansible
- Regular dependency updates (Dependabot)
- Daily security audits (CI)

See [../SECURITY.md](../SECURITY.md) and [ansible/playbooks/security-hardening.yml](../ansible/playbooks/security-hardening.yml).
