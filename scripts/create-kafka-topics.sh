#!/bin/bash
# Idempotent Kafka topic creation
set -e
BROKER=${BROKER:-localhost:9092}
TOPICS=(events state logs)
for TOPIC in "${TOPICS[@]}"; do
  kafka-topics.sh --create --if-not-exists --bootstrap-server "$BROKER" --topic "$TOPIC" --partitions 3 --replication-factor 1
  echo "Ensured topic: $TOPIC"
done
