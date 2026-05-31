#!/usr/bin/env bash
# Write the Pi-hole .env + compose file and start the container (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

docker network create homelab 2>/dev/null || true
mkdir -p ~/pihole && cd ~/pihole
if [ ! -f .env ]; then
  read -rp "Timezone [America/Denver]: " TZ; TZ=${TZ:-America/Denver}
  read -rsp "Pi-hole admin password (blank = generate): " PW; echo
  PW=${PW:-$(openssl rand -base64 18)}
  ( umask 177; printf 'TZ=%s\nPIHOLE_PASSWORD=%s\n' "$TZ" "$PW" > .env )
  echo "Wrote ~/pihole/.env (mode 600)."
fi
cat > compose.yaml <<'YAML'
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8081:80/tcp"
    environment:
      TZ: "${TZ}"
      FTLCONF_webserver_api_password: "${PIHOLE_PASSWORD:?set PIHOLE_PASSWORD in .env}"
      FTLCONF_dns_upstreams: "1.1.1.1;1.0.0.1"
      FTLCONF_dns_listeningMode: "ALL"
    volumes:
      - ./etc-pihole:/etc/pihole
    networks:
      - homelab
    restart: unless-stopped
networks:
  homelab:
    external: true
YAML
printf '.env\netc-pihole/\n' > .gitignore
docker compose up -d
