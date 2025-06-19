#!/bin/bash
# Base system hardening
set -e
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y curl wget git
