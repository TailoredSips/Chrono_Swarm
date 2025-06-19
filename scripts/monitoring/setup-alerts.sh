#!/bin/bash
# Setup monitoring alerts
set -e
cp deployment/monitoring/prometheus/alerts.yml /etc/prometheus/
echo "Prometheus alerts configured."
