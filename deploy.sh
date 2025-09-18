#!/usr/bin/env bash
set -euo pipefail

# Usage: ./deploy.sh [pull]
# - Requires: docker, docker compose, .env configured with images

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ "${1:-}" == "pull" ]]; then
  docker compose pull
fi

docker compose up -d
docker system prune -f --volumes || true
docker compose ps

echo "Deployment complete."


