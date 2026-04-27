#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Build Script"
echo "======================================"

IMAGE_NAME="${IMAGE_NAME:-devops-taskboard-api}"
IMAGE_TAG="${IMAGE_TAG:-local}"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

echo
echo "Checking Docker..."

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is not installed or not available."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not running."
  echo "Start Docker Desktop and make sure WSL2 integration is enabled."
  exit 1
fi

echo "Docker is available."

echo
echo "Checking application dependency lock file..."

if [ ! -f app/package-lock.json ]; then
  echo "ERROR: app/package-lock.json not found."
  echo "Run this first:"
  echo "  cd app && npm install && cd .."
  exit 1
fi

echo "package-lock.json exists."

echo
echo "Building Docker image:"
echo "$FULL_IMAGE_NAME"

docker build -t "$FULL_IMAGE_NAME" ./app

echo
echo "Docker image built successfully:"
docker images "$IMAGE_NAME"

echo
echo "Build completed successfully."
