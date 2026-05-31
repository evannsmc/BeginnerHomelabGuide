#!/usr/bin/env bash
# Deploy Caddy from this folder's Caddyfile + compose.yaml, export its root CA (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The homelab network is created by attach-services-to-network.sh (run that first).
mkdir -p ~/proxy
cp "$SD/Caddyfile"    ~/proxy/Caddyfile
cp "$SD/compose.yaml" ~/proxy/compose.yaml
( cd ~/proxy && docker compose up -d )
sleep 4
docker exec caddy cat /data/caddy/pki/authorities/local/root.crt > ~/proxy/caddy-root-ca.crt 2>/dev/null \
  && echo "Exported ~/proxy/caddy-root-ca.crt (trust it on your devices)." || echo "CA not ready yet; re-run this line shortly."
