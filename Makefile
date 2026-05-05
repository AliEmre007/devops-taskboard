.RECIPEPREFIX := >
.DEFAULT_GOAL := help

.PHONY: help bootstrap test build up down restart ps deploy rollback backup restore migrate logs logs-app logs-db logs-redis logs-nginx logs-prometheus logs-all health metrics structure status clean

help:
> @echo "Available commands:"
> @echo ""
> @echo "  make bootstrap        Prepare local environment"
> @echo "  make test             Run application tests"
> @echo "  make build            Build application image"
> @echo "  make up               Start all containers"
> @echo "  make down             Stop all containers"
> @echo "  make restart          Restart all containers"
> @echo "  make ps               Show container status"
> @echo "  make deploy           Deploy local stack"
> @echo "  make rollback         Rollback app image"
> @echo "  make backup           Backup PostgreSQL database"
> @echo "  make restore          Restore PostgreSQL database from latest backup"
> @echo "  make migrate          Run database migrations"
> @echo "  make health           Check application health"
> @echo "  make metrics          Show application metrics"
> @echo "  make status           Show project status"
> @echo "  make structure        Show folder structure"
> @echo "  make logs             Show app logs by default"
> @echo "  make logs SERVICE=nginx"
> @echo "  make logs-app         Show app logs"
> @echo "  make logs-db          Show PostgreSQL logs"
> @echo "  make logs-redis       Show Redis logs"
> @echo "  make logs-nginx       Show Nginx logs"
> @echo "  make logs-prometheus  Show Prometheus logs"
> @echo "  make logs-all         Show all service logs"
> @echo "  make clean            Stop containers and remove volumes"

bootstrap:
> ./scripts/bootstrap.sh

test:
> ./scripts/test.sh

build:
> ./scripts/build.sh

up:
> docker compose up -d --build

down:
> docker compose down

restart:
> docker compose down
> docker compose up -d --build

ps:
> docker compose ps

deploy:
> ./scripts/deploy.sh

rollback:
> ./scripts/rollback.sh

backup:
> ./scripts/backup-db.sh

restore:
> ./scripts/restore-db.sh

migrate:
> ./scripts/migrate-db.sh

logs:
> ./scripts/logs.sh $(SERVICE)

logs-app:
> ./scripts/logs.sh app

logs-db:
> ./scripts/logs.sh postgres

logs-redis:
> ./scripts/logs.sh redis

logs-nginx:
> ./scripts/logs.sh nginx

logs-prometheus:
> ./scripts/logs.sh prometheus

logs-all:
> ./scripts/logs.sh all

health:
> ./scripts/healthcheck.sh

metrics:
> @echo "Showing first 40 lines from application metrics:"
> @curl -s http://localhost:8080/metrics | head -40

status:
> @echo "=== Containers ==="
> docker compose ps
> @echo ""
> @echo "=== App Health ==="
> curl -fsS http://localhost:8080/health || true
> @echo ""
> @echo ""
> @echo "=== App Readiness ==="
> curl -fsS http://localhost:8080/ready || true
> @echo ""
> @echo ""
> @echo "=== Prometheus ==="
> curl -fsS http://localhost:9090/-/healthy || true

structure:
> tree -a -I ".git|node_modules"

clean:
> docker compose down -v --remove-orphans
