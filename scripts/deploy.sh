#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Deploy Script"
echo "======================================"

APP_IMAGE="devops-taskboard-api:local"
DEPLOY_DIR=".deploy"
PREVIOUS_IMAGE_FILE="$DEPLOY_DIR/previous_image_id"

HEALTH_URL="${HEALTH_URL:-http://localhost:8080/health}"
READY_URL="${READY_URL:-http://localhost:8080/ready}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-30}"
SLEEP_SECONDS="${SLEEP_SECONDS:-2}"

mkdir -p "$DEPLOY_DIR"

echo
echo "Saving current application image before deployment..."

if docker image inspect "$APP_IMAGE" >/dev/null 2>&1; then
  docker image inspect "$APP_IMAGE" --format '{{.Id}}' > "$PREVIOUS_IMAGE_FILE"
  echo "Previous image saved:"
  cat "$PREVIOUS_IMAGE_FILE"
else
  echo "No previous application image found. This may be the first deployment."
fi

echo
echo "Starting Docker Compose deployment..."

docker compose up -d --build

echo
echo "Waiting for application health endpoint..."

for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  if curl -fsS "$HEALTH_URL" >/dev/null; then
    echo "Application is healthy."
    break
  fi

  echo "Application is not healthy yet. Attempt $attempt/$MAX_ATTEMPTS..."
  sleep "$SLEEP_SECONDS"

  if [ "$attempt" -eq "$MAX_ATTEMPTS" ]; then
    echo
    echo "ERROR: Application did not become healthy in time."
    echo
    echo "Container status:"
    docker compose ps
    echo
    echo "Recent logs:"
    docker compose logs --tail=100
    exit 1
  fi
done

echo
echo "Running database migrations..."
./scripts/migrate-db.sh

echo
echo "Checking application health through Nginx..."
./scripts/healthcheck.sh "$HEALTH_URL"

echo
echo "Checking application readiness through Nginx..."
./scripts/healthcheck.sh "$READY_URL"

echo
echo "Checking Prometheus health..."
curl -fsS http://localhost:9090/-/healthy

echo
echo
echo "Deployment completed successfully."
