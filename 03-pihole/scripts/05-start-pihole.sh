#!/usr/bin/env bash
# Start Pi-hole after creating .env, compose.yaml, and .gitignore.
set -euo pipefail

for file in ~/pihole/.env ~/pihole/compose.yaml ~/pihole/.gitignore; do
  if [ ! -f "$file" ]; then
    echo "Missing $file. Run scripts 02 through 04 first." >&2
    exit 1
  fi
done

( cd ~/pihole && docker compose up -d )
echo "Pi-hole admin: http://$(grep '^PIHOLE_IP=' ~/pihole/.env | cut -d= -f2-)/admin"
