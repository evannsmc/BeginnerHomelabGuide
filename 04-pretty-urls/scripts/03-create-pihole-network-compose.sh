#!/usr/bin/env bash
# Replace ~/pihole/compose.yaml with the Chapter 4 networked version.
set -euo pipefail

mkdir -p ~/pihole
cat > ~/pihole/compose.yaml <<'EOF'
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
EOF
echo "Wrote ~/pihole/compose.yaml with port 80 freed and the homelab network attached."
