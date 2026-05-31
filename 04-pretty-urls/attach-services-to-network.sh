#!/usr/bin/env bash
# Create the homelab network and put Pi-hole + Audiobookshelf on it (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

# Chapter 4, Steps 1-2: create the shared 'homelab' network, widen Pi-hole onto
# the tailnet (all interfaces, web UI moved to 8081), and attach both Compose
# services to the network declaratively, then recreate them.
docker network create homelab 2>/dev/null || true

cat > ~/audiobookshelf/compose.yaml <<'YAML'
services:
  audiobookshelf:
    container_name: audiobookshelf
    image: ghcr.io/advplyr/audiobookshelf:latest
    ports:
      - "13378:80"
    volumes:
      - ./media/Audiobooks:/audiobooks
      - ./config:/config
      - ./metadata:/metadata
    networks:
      - homelab
    restart: unless-stopped
networks:
  homelab:
    external: true
YAML
( cd ~/audiobookshelf && docker compose up -d --force-recreate )

cat > ~/pihole/compose.yaml <<'YAML'
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
( cd ~/pihole && docker compose up -d --force-recreate )
echo "Pi-hole + Audiobookshelf are on the homelab network; Pi-hole web is now on :8081."
