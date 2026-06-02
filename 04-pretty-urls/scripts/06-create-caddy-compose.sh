#!/usr/bin/env bash
# Create ~/caddy/compose.yaml.
set -euo pipefail

mkdir -p ~/caddy
cat > ~/caddy/compose.yaml <<'EOF'
services:
  caddy:
    container_name: caddy
    image: caddy:latest
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - homelab
    restart: unless-stopped
networks:
  homelab:
    external: true
volumes:
  caddy_data:
  caddy_config:
EOF
echo "Wrote ~/caddy/compose.yaml."
