#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Bootstrap"
echo "======================================"

echo
echo "Current user:"
whoami

echo
echo "Current directory:"
pwd

echo
echo "Checking required commands..."

required_commands=("git" "curl")

for cmd in "${required_commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd is installed"
  else
    echo "ERROR: $cmd is not installed"
    exit 1
  fi
done

echo
echo "Checking environment file..."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
else
  echo ".env already exists"
fi

echo
echo "Creating local runtime folders..."

mkdir -p backups
mkdir -p .deploy

echo "Created backups/ and .deploy/ if they did not exist"

echo
echo "Git status:"
git status --short

echo
echo "Bootstrap completed successfully."
