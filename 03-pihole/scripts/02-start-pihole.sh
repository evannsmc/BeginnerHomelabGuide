#!/usr/bin/env bash
# Create the .env and install ../compose/compose.yaml, then start Pi-hole (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; C="$SD/../compose"

mkdir -p ~/pihole && cd ~/pihole
if [ ! -f .env ]; then
  read -rp "Timezone [America/Denver]: " TZ; TZ=${TZ:-America/Denver}
  DEF_IP=$(hostname -I | awk '{print $1}')
  read -rp "Pi LAN IP [$DEF_IP]: " IP; IP=${IP:-$DEF_IP}
  read -rsp "Pi-hole admin password (blank = generate): " PW; echo
  PW=${PW:-$(openssl rand -base64 18)}
  ( umask 177; printf 'TZ=%s\nPIHOLE_PASSWORD=%s\nPIHOLE_IP=%s\n' "$TZ" "$PW" "$IP" > .env )
  echo "Wrote ~/pihole/.env (mode 600)."
fi
cp "$C/compose.yaml" ~/pihole/compose.yaml
printf '.env\netc-pihole/\n' > ~/pihole/.gitignore
docker compose up -d
echo "Pi-hole admin: http://$(grep '^PIHOLE_IP=' .env | cut -d= -f2-)/admin"
