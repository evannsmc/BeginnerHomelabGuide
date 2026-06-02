#!/usr/bin/env bash
# Start Caddy and export its local root CA certificate.
set -euo pipefail

( cd ~/caddy && docker compose up -d )
sleep 4
docker exec caddy cat /data/caddy/pki/authorities/local/root.crt > ~/caddy/caddy-root-ca.crt 2>/dev/null \
  && echo "Exported ~/caddy/caddy-root-ca.crt (trust it on your devices)." \
  || echo "CA not ready yet; rerun: docker exec caddy cat /data/caddy/pki/authorities/local/root.crt > ~/caddy/caddy-root-ca.crt"
