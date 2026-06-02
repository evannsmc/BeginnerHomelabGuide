#!/usr/bin/env bash
# Create ~/pihole/.env for Pi-hole settings and the admin password.
set -euo pipefail

mkdir -p ~/pihole
cd ~/pihole

if [ -f .env ]; then
  echo "~/pihole/.env already exists; leaving it alone."
  exit 0
fi

read -rp "Timezone [America/Denver]: " TZ
TZ=${TZ:-America/Denver}
DEF_IP=$(hostname -I | awk '{print $1}')
read -rp "Pi LAN IP [$DEF_IP]: " IP
IP=${IP:-$DEF_IP}
read -rsp "Pi-hole admin password (blank = generate): " PW
echo
PW=${PW:-$(openssl rand -base64 18)}

( umask 177; printf 'TZ=%s\nPIHOLE_PASSWORD=%s\nPIHOLE_IP=%s\n' "$TZ" "$PW" "$IP" > .env )
echo "Wrote ~/pihole/.env (mode 600)."
