#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Rollback Script"
echo "======================================"

APP_IMAGE="devops-taskboard-api:local"
DEPLOY_DIR=".deploy"
PREVIOUS_IMAGE_FILE="$DEPLOY_DIR/previous_image_id"

HEALTH_URL="${HEALTH_URL:-http://localhost:8080/health}"
READY_URL="${READY_URL:-http://localhost:8080/ready}"

if [ ! -f "$PREVIOUS_IMAGE_FILE" ]; then
  echo "ERROR: No previous image record found."
  echo
  echo "Rollback is not possible yet."
  echo "Run at least one successful deployment first:"
  echo "  make deploy"
  exit 1
fi

PREVIOUS_IMAGE_ID="$(cat "$PREVIOUS_IMAGE_FILE")"

echo
echo "Previous image ID:"
echo "$PREVIOUS_IMAGE_ID"

echo
echo "Checking if previous image exists locally..."

if ! docker image inspect "$PREVIOUS_IMAGE_ID" >/dev/null 2>&1; then
  echo "ERROR: Previous image does not exist locally anymore."
  echo
  echo "It may have been removed by Docker cleanup commands."
  echo "Rollback cannot continue."
  exit 1
fi

echo "Previous image exists."

echo
echo "Re-tagging previous image as current app image..."
docker tag "$PREVIOUS_IMAGE_ID" "$APP_IMAGE"

echo
echo "Restarting application stack without rebuilding..."
docker compose up -d --no-build

echo
echo "Checking application health after rollback..."
./scripts/healthcheck.sh "$HEALTH_URL"

echo
echo "Checking application readiness after rollback..."
./scripts/healthcheck.sh "$READY_URL"

echo
echo "Rollback completed successfully."
