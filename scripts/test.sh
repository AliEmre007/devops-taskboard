#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Test Script"
echo "======================================"

echo
echo "Checking project structure..."

required_dirs=(
  "app"
  "app/src"
  "app/tests"
  "nginx"
  "scripts"
  "infra"
  "infra/terraform"
  "infra/ansible"
  "k8s"
  "monitoring"
  "monitoring/grafana"
  ".github"
  ".github/workflows"
)

for dir in "${required_dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo "OK: directory exists -> $dir"
  else
    echo "ERROR: missing directory -> $dir"
    exit 1
  fi
done

echo
echo "Checking required files..."

required_files=(
  ".gitignore"
  ".env.example"
  "README.md"
  "runbook.md"
  "Makefile"
  "docker-compose.yml"
  "docker-compose.prod.yml"
  "app/package.json"
  "app/Dockerfile"
  "nginx/nginx.conf"
  "scripts/bootstrap.sh"
  "scripts/test.sh"
  "scripts/build.sh"
  "scripts/deploy.sh"
  "scripts/rollback.sh"
  "scripts/healthcheck.sh"
  "scripts/backup-db.sh"
  "scripts/logs.sh"
  "k8s/namespace.yaml"
  "k8s/deployment.yaml"
  "k8s/service.yaml"
  "k8s/ingress.yaml"
  "monitoring/prometheus.yml"
  ".github/workflows/ci.yml"
  ".github/workflows/cd.yml"
)

for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    echo "OK: file exists -> $file"
  else
    echo "ERROR: missing file -> $file"
    exit 1
  fi
done

echo
echo "Checking environment files..."

if [ -f ".env.example" ]; then
  echo "OK: .env.example exists"
else
  echo "ERROR: .env.example is missing"
  exit 1
fi

if [ -f ".env" ]; then
  echo "OK: .env exists locally"
else
  echo "WARNING: .env does not exist. Run ./scripts/bootstrap.sh"
fi

echo
echo "Checking shell script syntax..."

for script in scripts/*.sh; do
  echo "Checking syntax: $script"
  bash -n "$script"
done

echo
echo "Checking executable permissions..."

for script in scripts/*.sh; do
  if [ -x "$script" ]; then
    echo "OK: executable -> $script"
  else
    echo "ERROR: script is not executable -> $script"
    echo "Fix with: chmod +x $script"
    exit 1
  fi
done

echo
echo "All project structure tests passed successfully."
