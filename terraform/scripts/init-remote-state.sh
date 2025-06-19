#!/bin/bash
# Bootstrap remote state
set -e
aws s3 mb s3://chrono-swarm-tfstate || true
aws s3api put-bucket-versioning --bucket chrono-swarm-tfstate --versioning-configuration Status=Enabled
