#!/bin/bash
# Backup and restore procedures
set -e
MODE=$1
BACKUP_DIR=${BACKUP_DIR:-/var/backups/chrono-swarm}
DB_URL=${DB_URL:-postgres://chrono:swarm@localhost/chrono}

case "$MODE" in
  backup)
    mkdir -p "$BACKUP_DIR"
    pg_dump "$DB_URL" > "$BACKUP_DIR/chrono_backup_$(date +%F_%T).sql"
    echo "Backup complete."
    ;;
  restore)
    if [ -z "$2" ]; then
      echo "Usage: $0 restore <backup_file.sql>"
      exit 1
    fi
    psql "$DB_URL" < "$2"
    echo "Restore complete."
    ;;
  *)
    echo "Usage: $0 {backup|restore} [backup_file]"
    exit 1
    ;;
esac
