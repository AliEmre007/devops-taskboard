#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Logs Script"
echo "======================================"

SERVICE="${1:-app}"

echo
echo "Showing logs for service: $SERVICE"
echo

docker compose logs -f "$SERVICE"
