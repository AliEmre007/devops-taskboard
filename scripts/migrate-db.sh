#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Database Migrations"
echo "======================================"

ENV_FILE="${ENV_FILE:-.env}"
COMPOSE_ARGS="${COMPOSE_ARGS:-}"

compose() {
  if [ -n "$COMPOSE_ARGS" ]; then
    # shellcheck disable=SC2086
    docker compose $COMPOSE_ARGS "$@"
  else
    docker compose "$@"
  fi
}

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: environment file not found: $ENV_FILE"
  echo
  echo "For local:"
  echo "  make bootstrap"
  echo
  echo "For production-like:"
  echo "  cp .env .env.prod"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

POSTGRES_USER="${POSTGRES_USER:-taskboard_user}"
POSTGRES_DB="${POSTGRES_DB:-taskboard}"
MIGRATIONS_DIR="./app/db/migrations"

if [ ! -d "$MIGRATIONS_DIR" ]; then
  echo "ERROR: migrations directory not found: $MIGRATIONS_DIR"
  exit 1
fi

echo
echo "Environment file: $ENV_FILE"
echo "PostgreSQL database: $POSTGRES_DB"
echo "PostgreSQL user: $POSTGRES_USER"

echo
echo "Checking PostgreSQL service..."

if ! compose ps postgres | grep -q "running\|Up"; then
  echo "ERROR: PostgreSQL service is not running."
  echo
  echo "Start the stack first:"
  echo "  make up"
  echo
  echo "Or for production-like:"
  echo "  make prod-up"
  exit 1
fi

echo "PostgreSQL is running."

echo
echo "Ensuring schema_migrations table exists..."

compose exec -T postgres psql \
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
    compose exec -T postgres psql \
      -U "$POSTGRES_USER" \
      -d "$POSTGRES_DB" \
      -tAc "SELECT 1 FROM schema_migrations WHERE filename = '$filename';"
  )"

  if [ "$already_applied" = "1" ]; then
    echo "SKIP: $filename already applied"
  else
    echo "APPLY: $filename"

    compose exec -T postgres psql \
      -U "$POSTGRES_USER" \
      -d "$POSTGRES_DB" < "$migration"

    compose exec -T postgres psql \
      -U "$POSTGRES_USER" \
      -d "$POSTGRES_DB" \
      -c "INSERT INTO schema_migrations (filename) VALUES ('$filename');"

    echo "DONE: $filename"
  fi
done

echo
echo "Migrations completed successfully."
