#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Database Migrations"
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
MIGRATIONS_DIR="./app/db/migrations"

if [ ! -d "$MIGRATIONS_DIR" ]; then
  echo "ERROR: migrations directory not found: $MIGRATIONS_DIR"
  exit 1
fi

echo
echo "Checking PostgreSQL service..."

if ! docker compose ps postgres | grep -q "running\|Up"; then
  echo "ERROR: PostgreSQL service is not running."
  echo
  echo "Start the stack first:"
  echo "  make up"
  exit 1
fi

echo "PostgreSQL is running."

echo
echo "Ensuring schema_migrations table exists..."

docker compose exec -T postgres psql \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -c "CREATE TABLE IF NOT EXISTS schema_migrations (
        filename TEXT PRIMARY KEY,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );"

echo
echo "Applying pending migrations..."

shopt -s nullglob
migrations=("$MIGRATIONS_DIR"/*.sql)
shopt -u nullglob

if [ "${#migrations[@]}" -eq 0 ]; then
  echo "No migration files found in: $MIGRATIONS_DIR"
  exit 0
fi

for migration in "${migrations[@]}"; do
  filename="$(basename "$migration")"

  already_applied="$(
    docker compose exec -T postgres psql \
      -U "$POSTGRES_USER" \
      -d "$POSTGRES_DB" \
      -tAc "SELECT 1 FROM schema_migrations WHERE filename = '$filename';"
  )"

  if [ "$already_applied" = "1" ]; then
    echo "SKIP: $filename already applied"
  else
    echo "APPLY: $filename"

    docker compose exec -T postgres psql \
      -U "$POSTGRES_USER" \
      -d "$POSTGRES_DB" < "$migration"

    docker compose exec -T postgres psql \
      -U "$POSTGRES_USER" \
      -d "$POSTGRES_DB" \
      -c "INSERT INTO schema_migrations (filename) VALUES ('$filename');"

    echo "DONE: $filename"
  fi
done

echo
echo "Migrations completed successfully."
