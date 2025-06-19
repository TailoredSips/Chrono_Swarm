#!/bin/bash
# DR environment setup
set -e
aws s3 mb s3://chrono-swarm-dr-tfstate || true
aws s3api put-bucket-versioning --bucket chrono-swarm-dr-tfstate --versioning-configuration Status=Enabled
