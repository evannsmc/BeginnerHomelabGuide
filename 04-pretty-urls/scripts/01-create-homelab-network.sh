#!/usr/bin/env bash
# Create the shared Docker network Caddy and the app containers use.
set -euo pipefail

docker network create homelab 2>/dev/null || true
echo "Docker network 'homelab' exists."
