#!/usr/bin/env bash
# Part 4 — Pretty URLs: Caddy reverse proxy + Pi-hole local DNS. Run this ON the Pi.
#
# Creates the shared 'homelab' network, widens Pi-hole onto the tailnet, deploys
# Caddy as the single port-80 front door, and adds the .home DNS records. The
# Caddyfile is pre-wired for the Part 5 dashboard (home.home) too, so you don't
# have to edit it again. The Tailscale admin-console DNS push is manual (below).
set -euo pipefail

echo "==> Creating the shared 'homelab' Docker network"
docker network create homelab 2>/dev/null && echo "    created" || echo "    already exists"

# Audiobookshelf runs from 'docker run' (Part 2), so attach it imperatively.
if docker ps -a --format '{{.Names}}' | grep -qx audiobookshelf; then
  docker network connect homelab audiobookshelf 2>/dev/null || true
  echo "    attached audiobookshelf to homelab"
fi

echo "==> Rewriting ~/pihole/compose.yaml: all-interfaces + 8081 web + homelab network"
# Pi-hole joins 'homelab' DECLARATIVELY so a --force-recreate always re-attaches
# it (a hand 'docker network connect' would be wiped by the recreate).
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

echo "==> Deploying Caddy (~/proxy)"
mkdir -p ~/proxy
cat > ~/proxy/Caddyfile <<'CADDY'
# http:// = plain HTTP, no TLS cert fetch (there's no public CA for a .home name).
http://pihole.home {
	redir / /admin 302
	reverse_proxy pihole:80
}

http://abs.home {
	reverse_proxy audiobookshelf:80
}

# Pre-wired for Part 5's dashboard (homepage). Until Part 5 runs, this route
# simply has no backend yet — harmless.
http://home.home, http://homelab {
	reverse_proxy homepage:3000
}
CADDY

cat > ~/proxy/compose.yaml <<'YAML'
services:
  caddy:
    container_name: caddy
    image: caddy:latest
    ports:
      - "80:80"
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
YAML
( cd ~/proxy && docker compose up -d )

echo "==> Adding Pi-hole local DNS records -> the Pi's Tailscale IP"
TSIP=$(tailscale ip -4 | head -1)
docker exec pihole pihole-FTL --config dns.hosts \
  "[ \"$TSIP pihole.home\", \"$TSIP abs.home\", \"$TSIP home.home\" ]"
echo "    pihole.home / abs.home / home.home -> $TSIP"

cat <<NOTE

================================ MANUAL STEP ================================
Make Pi-hole your tailnet's DNS (Tailscale admin console -> DNS page):
  1. Add nameserver -> Custom: enter  $TSIP
       Restrict to domain: OFF      Use with exit node: OFF
  2. Turn ON "Override local DNS".
Then from any device on the tailnet:  ping home.home   (should answer from $TSIP)
============================================================================
NOTE
