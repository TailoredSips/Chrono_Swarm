# Chrono Swarm Architecture

_This document describes the complete system architecture, including service boundaries, data flows, and deployment topologies._

## Overview
Chrono Swarm is a modular, event-driven orchestration platform for distributed compute workloads. It is composed of loosely coupled Rust microservices, a robust event streaming backbone, and a declarative infrastructure layer.

- **Orchestration:** `cs-orchestrator`, `cs-scheduler`, `cs-reconciler`
- **Execution:** `cs-spawner`, `cs-agent`, `cs-materializer`
- **Data/State:** `cs-core`, `cs-cache`, `cs-bayes-engine`
- **API/CLI:** `cs-api`, `chrono-cli`
- **Observability:** `cs-watchdog`, `cs-nervous-system`

## Service Topology
```
[User/CLI]
   |
[cs-api] <-> [cs-orchestrator] <-> [cs-scheduler] <-> [cs-spawner]
   |                |                  |                |
[cs-core]      [cs-reconciler]     [cs-materializer]   [cs-agent]
   |                |                  |                |
[cs-cache] <-> [cs-bayes-engine] <-> [cs-nervous-system] <-> [cs-watchdog]
```

## Data Flows
- Event sourcing and streaming via Kafka
- State materialization and caching
- Secure agent sandboxing and lifecycle

## Deployment
- Infrastructure as Code (Terraform, Ansible, Packer)
- Multi-cloud, multi-region support
- Automated disaster recovery

See [deployment.md](deployment.md) for details.
