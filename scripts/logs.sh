#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " DevOps TaskBoard Logs Script"
echo "======================================"

SERVICE="${1:-app}"
TAIL_LINES="${TAIL_LINES:-100}"

echo
echo "Showing logs for: $SERVICE"
echo "Tail lines: $TAIL_LINES"
echo

if [ "$SERVICE" = "all" ]; then
  docker compose logs -f --tail="$TAIL_LINES"
else
  docker compose logs -f --tail="$TAIL_LINES" "$SERVICE"
fi
