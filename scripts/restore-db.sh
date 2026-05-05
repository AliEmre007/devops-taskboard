#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Database Restore"
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

BACKUP_FILE="${1:-./backups/latest.sql.gz}"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "ERROR: Backup file not found:"
  echo "$BACKUP_FILE"
  echo
  echo "Usage:"
  echo "  ./scripts/restore-db.sh ./backups/example.sql.gz"
  echo
  echo "Or restore latest backup:"
  echo "  ./scripts/restore-db.sh"
  exit 1
fi

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
echo "Restoring backup:"
echo "$BACKUP_FILE"

echo
echo "WARNING: This will drop and recreate the database:"
echo "$POSTGRES_DB"
echo

docker compose exec -T postgres psql \
  -U "$POSTGRES_USER" \
  -d postgres \
  -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$POSTGRES_DB' AND pid <> pg_backend_pid();"

docker compose exec -T postgres psql \
  -U "$POSTGRES_USER" \
  -d postgres \
  -c "DROP DATABASE IF EXISTS $POSTGRES_DB;"

docker compose exec -T postgres psql \
  -U "$POSTGRES_USER" \
  -d postgres \
  -c "CREATE DATABASE $POSTGRES_DB;"

echo
echo "Importing backup into database..."

gunzip -c "$BACKUP_FILE" | docker compose exec -T postgres psql \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB"

echo
echo "Database restore completed successfully."
