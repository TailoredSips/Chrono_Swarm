# Chrono Swarm Disaster Recovery

_This document describes disaster recovery (DR) procedures and runbooks._

## DR Principles
- Cross-region replication of state and data
- Automated failover and recovery
- Regular DR testing

## Procedures
1. **Trigger DR failover:**
   - Use Terraform to promote standby resources
   - Update DNS and service endpoints
2. **Restore from backup:**
   - Use backup-restore.sh script
   - Validate data integrity
3. **Test DR readiness:**
   - Run chaos tests in `testing/chaos/`

See [terraform/modules/disaster-recovery/](../terraform/modules/disaster-recovery/) and [scripts/backup-restore.sh](../scripts/backup-restore.sh).
