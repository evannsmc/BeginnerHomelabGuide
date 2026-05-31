#!/usr/bin/env bash
# Install ../compose/ (compose + config) and start Homepage + Portainer (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; C="$SD/../compose"

mkdir -p ~/dashboard
cp "$C/compose.yaml" ~/dashboard/compose.yaml
cp -r "$C/config" ~/dashboard/
SUFFIX=$(tailscale status --json 2>/dev/null | grep -o '"MagicDNSSuffix":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$SUFFIX" ] && sed -i "s/homelab\\.your-tailnet\\.ts\\.net/homelab.$SUFFIX/" ~/dashboard/compose.yaml
if [ ! -f ~/dashboard/.env ]; then
  PW=$(grep -h '^PIHOLE_PASSWORD=' ~/pihole/.env 2>/dev/null | cut -d= -f2- || true)
  read -rp "Audiobookshelf API token (blank OK): " TOK
  ( umask 177; printf 'PIHOLE_PASSWORD=%s\nABS_TOKEN=%s\n' "$PW" "$TOK" > ~/dashboard/.env )
fi
printf '.env\n' > ~/dashboard/.gitignore
( cd ~/dashboard && docker compose up -d )
echo "Dashboard up. Open http://home.home (create the Portainer admin promptly at https://homelab:9443)."
