#!/usr/bin/env bash
# Create ~/dashboard/compose.yaml.
set -euo pipefail

mkdir -p ~/dashboard
cat > ~/dashboard/compose.yaml <<'EOF'
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      # Hostnames Caddy will forward here. Comma-separated, NO spaces.
      HOMEPAGE_ALLOWED_HOSTS: home.home,homelab,homelab.your-tailnet.ts.net
      # Widget secrets, injected from .env: never hard-coded in the config files.
      HOMEPAGE_VAR_PIHOLE_PASSWORD: ${PIHOLE_PASSWORD:?set PIHOLE_PASSWORD in .env}
      HOMEPAGE_VAR_ABS_TOKEN: ${ABS_TOKEN:-}
    networks:
      - homelab
    restart: unless-stopped

  portainer:
    image: portainer/portainer-ce:lts
    container_name: portainer
    ports:
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - homelab
    restart: always

networks:
  homelab:
    external: true

volumes:
  portainer_data:
EOF

SUFFIX=$(tailscale status --json 2>/dev/null | grep -o '"MagicDNSSuffix":"[^"]*"' | head -1 | cut -d'"' -f4 || true)
if [ -n "$SUFFIX" ]; then
  sed -i "s/homelab\\.your-tailnet\\.ts\\.net/homelab.$SUFFIX/" ~/dashboard/compose.yaml
fi

echo "Wrote ~/dashboard/compose.yaml."
