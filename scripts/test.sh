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
  "app/package.json"
  "app/src/server.js"
  "app/tests/server.test.js"
  "scripts/bootstrap.sh"
  "scripts/test.sh"
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
echo "Checking shell script syntax..."

for script in scripts/*.sh; do
  echo "Checking syntax: $script"
  bash -n "$script"
done

echo
echo "Checking JavaScript syntax..."

cd app
npm run lint

echo
echo "Running application tests..."

npm test

cd ..

echo
echo "All tests passed successfully."
