#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Health Check Script"
echo "======================================"

URL="${1:-http://localhost:8080/health}"

echo
echo "Checking health endpoint:"
echo "$URL"

HTTP_CODE="$(curl -s -o /tmp/taskboard_health_response.txt -w "%{http_code}" "$URL" || true)"

if [ "$HTTP_CODE" = "200" ]; then
  echo
  echo "Health check passed."
  echo "Response body:"
  cat /tmp/taskboard_health_response.txt
  echo
else
  echo
  echo "Health check failed."
  echo "HTTP code: $HTTP_CODE"
  echo
  echo "Response body:"
  cat /tmp/taskboard_health_response.txt || true
  echo
  echo "Hint: make sure the stack is running:"
  echo "  make up"
  exit 1
fi
