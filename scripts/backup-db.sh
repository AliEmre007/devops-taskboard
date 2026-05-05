#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Database Backup"
echo "======================================"

if [ ! -f .env ]; then
  echo "ERROR: .env file not found."
  echo "Run:"
  echo "  make bootstrap"
  exit 1
fi

set -a
source .env
set +a

POSTGRES_USER="${POSTGRES_USER:-taskboard_user}"
POSTGRES_DB="${POSTGRES_DB:-taskboard}"

BACKUP_DIR="./backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/taskboard_${TIMESTAMP}.sql"
COMPRESSED_BACKUP_FILE="${BACKUP_FILE}.gz"
LATEST_BACKUP_FILE="$BACKUP_DIR/latest.sql.gz"

mkdir -p "$BACKUP_DIR"

echo
echo "Checking if PostgreSQL container is running..."

if ! docker compose ps postgres | grep -q "running\|Up"; then
  echo "ERROR: PostgreSQL service does not seem to be running."
  echo
  echo "Start the stack first:"
  echo "  make up"
  exit 1
fi

echo "PostgreSQL service is running."

echo
echo "Creating backup:"
echo "$BACKUP_FILE"

docker compose exec -T postgres pg_dump \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" > "$BACKUP_FILE"

gzip "$BACKUP_FILE"

cp "$COMPRESSED_BACKUP_FILE" "$LATEST_BACKUP_FILE"

echo
echo "Backup completed successfully:"
echo "$COMPRESSED_BACKUP_FILE"

echo
echo "Latest backup pointer:"
echo "$LATEST_BACKUP_FILE"

echo
echo "Backup size:"
ls -lh "$COMPRESSED_BACKUP_FILE"
