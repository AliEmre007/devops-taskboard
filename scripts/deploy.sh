#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Deploy Script"
echo "======================================"

echo
echo "Starting Docker Compose deployment..."

docker compose up -d --build

echo
echo "Waiting for application through Nginx..."
sleep 8

./scripts/healthcheck.sh http://localhost:8080/health

echo
echo "Deployment completed successfully."
