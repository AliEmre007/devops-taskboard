#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Deploy Script"
echo "======================================"

echo
echo "Starting Docker Compose deployment..."

docker compose up -d --build

echo
echo "Waiting for services..."
sleep 10

echo
echo "Running database migrations..."
./scripts/migrate-db.sh

echo
echo "Checking application health through Nginx..."
./scripts/healthcheck.sh http://localhost:8080/health

echo
echo "Checking application readiness through Nginx..."
./scripts/healthcheck.sh http://localhost:8080/ready

echo
echo "Deployment completed successfully."
