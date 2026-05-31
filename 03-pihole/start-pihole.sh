#!/usr/bin/env bash
# Write the Pi-hole .env + compose and start it (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

# Chapter 3 layout: Pi-hole bound to the Pi's LAN IP on port 80, no shared
# network yet. Chapter 4 widens it (all interfaces, port 8081, homelab network).
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
cat > compose.yaml <<'YAML'
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "${PIHOLE_IP}:53:53/tcp"
      - "${PIHOLE_IP}:53:53/udp"
      - "${PIHOLE_IP}:80:80/tcp"
    environment:
      TZ: "${TZ}"
      FTLCONF_webserver_api_password: "${PIHOLE_PASSWORD:?set PIHOLE_PASSWORD in .env}"
      FTLCONF_dns_upstreams: "1.1.1.1;1.0.0.1"
      FTLCONF_dns_listeningMode: "ALL"
    volumes:
      - ./etc-pihole:/etc/pihole
    restart: unless-stopped
YAML
printf '.env\netc-pihole/\n' > .gitignore
docker compose up -d
echo "Pi-hole admin: http://$(grep '^PIHOLE_IP=' .env | cut -d= -f2-)/admin"
