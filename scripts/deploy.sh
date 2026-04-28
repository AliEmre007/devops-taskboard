#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Deploy Script"
echo "======================================"

echo
echo "Starting Docker Compose deployment..."

docker compose up -d --build

echo
echo "Waiting for application to become healthy..."
sleep 5

./scripts/healthcheck.sh http://localhost:3000/health

echo
echo "Deployment completed successfully."
