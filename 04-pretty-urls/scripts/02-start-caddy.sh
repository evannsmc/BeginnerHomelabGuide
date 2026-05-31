#!/usr/bin/env bash
# Install ../compose/Caddyfile + caddy compose, start Caddy, export its root CA (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; C="$SD/../compose"

mkdir -p ~/proxy
cp "$C/Caddyfile"           ~/proxy/Caddyfile
cp "$C/caddy.compose.yaml"  ~/proxy/compose.yaml
( cd ~/proxy && docker compose up -d )
sleep 4
docker exec caddy cat /data/caddy/pki/authorities/local/root.crt > ~/proxy/caddy-root-ca.crt 2>/dev/null \
  && echo "Exported ~/proxy/caddy-root-ca.crt (trust it on your devices)." || echo "CA not ready yet; re-run this line shortly."
