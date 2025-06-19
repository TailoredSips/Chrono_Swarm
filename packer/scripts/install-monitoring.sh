#!/bin/bash
# Monitoring agents installation
set -e
sudo apt-get update
sudo apt-get install -y prometheus-node-exporter
sudo systemctl enable prometheus-node-exporter
sudo systemctl start prometheus-node-exporter
