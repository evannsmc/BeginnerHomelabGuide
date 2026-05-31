#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Heads up: this script automates MY homelab, for MY use case (see the repo
# README). It's a worked example to read and adapt, not a one-size-fits-all
# installer. Read it before you run it, and change anything that doesn't fit
# your hardware, your services, or what you actually need.
# ---------------------------------------------------------------------------
# Part 5 — Dashboard (Homepage + Portainer) at http://home.home. Run this ON the Pi.
#
# Homepage has no host port — Caddy (Part 4) fronts it. Portainer keeps :9443.
# Secrets (Pi-hole password reused, Audiobookshelf token) come from a gitignored
# .env. The Caddy route + Pi-hole record for home.home were created in Part 4.
set -euo pipefail

mkdir -p ~/dashboard/config
cd ~/dashboard

# Detect the tailnet suffix so HOMEPAGE_ALLOWED_HOSTS includes the Pi's full name.
SUFFIX=$(tailscale status --json 2>/dev/null | grep -o '"MagicDNSSuffix":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -n "$SUFFIX" ]; then ALLOWED="home.home,homelab,homelab.$SUFFIX"; else ALLOWED="home.home,homelab"; fi

if [ -f .env ]; then
  echo "==> ~/dashboard/.env exists — keeping it"
else
  echo "==> Creating ~/dashboard/.env"
  PW=$(grep -h '^PIHOLE_PASSWORD=' ~/pihole/.env 2>/dev/null | cut -d= -f2- || true)
  read -rp "    Audiobookshelf API token (UI: Settings->Users->you->API token; blank OK): " ABS_TOK
  ( umask 177; cat > .env <<EOF
PIHOLE_PASSWORD=$PW
ABS_TOKEN=$ABS_TOK
EOF
  )
  echo "    wrote ~/dashboard/.env (mode 600)"
fi
printf '.env\n' > .gitignore

echo "==> Writing ~/dashboard/compose.yaml (ALLOWED_HOSTS=$ALLOWED)"
# Quoted heredoc keeps ${...} literal; we inject ALLOWED via a post-edit so no
# secret is ever written into the file.
cat > compose.yaml <<'YAML'
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      HOMEPAGE_ALLOWED_HOSTS: __ALLOWED__
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
YAML
sed -i "s#__ALLOWED__#$ALLOWED#" compose.yaml

echo "==> Writing dashboard config (tiles, widgets, bookmarks)"
cat > config/settings.yaml <<'YAML'
title: My Homelab
theme: dark
color: slate
headerStyle: boxed
layout:
  Media: { style: row, columns: 2 }
  Network: { style: row, columns: 2 }
  Management: { style: row, columns: 2 }
  Links: { style: row, columns: 4 }
YAML

cat > config/docker.yaml <<'YAML'
my-docker:
  socket: /var/run/docker.sock
YAML

cat > config/services.yaml <<'YAML'
- Media:
    - Audiobookshelf:
        icon: audiobookshelf.png
        href: http://abs.home
        description: Audiobooks & language courses
        server: my-docker
        container: audiobookshelf
        widget:
          type: audiobookshelf
          url: http://audiobookshelf:80
          key: '{{HOMEPAGE_VAR_ABS_TOKEN}}'

- Network:
    - Pi-hole:
        icon: pi-hole.png
        href: http://pihole.home
        description: DNS ad-blocking
        server: my-docker
        container: pihole
        widget:
          type: pihole
          url: http://pihole:80
          version: 6
          key: '{{HOMEPAGE_VAR_PIHOLE_PASSWORD}}'

- Management:
    - Portainer:
        icon: portainer.png
        href: https://homelab:9443
        description: Manage Docker containers
YAML

cat > config/widgets.yaml <<'YAML'
- resources: { cpu: true, memory: true, disk: / }
- search: { provider: duckduckgo, target: _blank }
- datetime:
    format: { timeStyle: short }
- greeting: { text_size: xl, text: Welcome to the homelab }
YAML

cat > config/bookmarks.yaml <<'YAML'
- Links:
    - Tailscale admin:
        - { abbr: TS, href: https://login.tailscale.com/admin/machines }
    - Router:
        - { abbr: RT, href: http://192.168.1.1 }
    - Pi-hole docs:
        - { abbr: PH, href: https://docs.pi-hole.net }
    - Audiobookshelf docs:
        - { abbr: AB, href: https://www.audiobookshelf.org/docs }
YAML

echo "==> Starting the dashboard stack"
docker compose up -d
echo
echo "==> Open http://home.home (or http://homelab). Create the Portainer admin"
echo "    user PROMPTLY at https://homelab:9443 (it locks after a few minutes)."
