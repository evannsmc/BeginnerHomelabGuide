#!/usr/bin/env bash
# Start Homepage and Portainer after creating compose, .env, and config files.
set -euo pipefail

for path in ~/dashboard/compose.yaml ~/dashboard/.env ~/dashboard/config; do
  if [ ! -e "$path" ]; then
    echo "Missing $path. Run scripts 01 through 03 first." >&2
    exit 1
  fi
done

( cd ~/dashboard && docker compose up -d )
echo "Dashboard stack is up. Create the Portainer admin promptly at https://homelab:9443."
