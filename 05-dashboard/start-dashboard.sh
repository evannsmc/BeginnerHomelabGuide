#!/usr/bin/env bash
# Write the Homepage + Portainer compose file and start them (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

mkdir -p ~/dashboard/config && cd ~/dashboard
SUFFIX=$(tailscale status --json 2>/dev/null | grep -o '"MagicDNSSuffix":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$SUFFIX" ] && ALLOWED="home.home,homelab,homelab.$SUFFIX" || ALLOWED="home.home,homelab"
if [ ! -f .env ]; then
  PW=$(grep -h '^PIHOLE_PASSWORD=' ~/pihole/.env 2>/dev/null | cut -d= -f2- || true)
  read -rp "Audiobookshelf API token (blank OK): " TOK
  ( umask 177; printf 'PIHOLE_PASSWORD=%s\nABS_TOKEN=%s\n' "$PW" "$TOK" > .env )
fi
printf '.env\n' > .gitignore
cat > compose.yaml <<YAML
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      HOMEPAGE_ALLOWED_HOSTS: $ALLOWED
      HOMEPAGE_VAR_PIHOLE_PASSWORD: \${PIHOLE_PASSWORD:?set PIHOLE_PASSWORD in .env}
      HOMEPAGE_VAR_ABS_TOKEN: \${ABS_TOKEN:-}
    networks: [homelab]
    restart: unless-stopped
  portainer:
    image: portainer/portainer-ce:lts
    container_name: portainer
    ports: ["9443:9443"]
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks: [homelab]
    restart: always
networks:
  homelab:
    external: true
volumes:
  portainer_data:
YAML
docker compose up -d
echo "Dashboard up. Tile config (services.yaml etc.) is described in this part's README."
