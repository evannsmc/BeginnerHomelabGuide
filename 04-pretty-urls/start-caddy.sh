#!/usr/bin/env bash
# Write the Caddy config + compose file, start it, and export its root CA (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

docker network create homelab 2>/dev/null || true
mkdir -p ~/proxy && cd ~/proxy
cat > Caddyfile <<'CADDY'
# tls internal: Caddy makes its own private CA and serves HTTPS for .home names.
pihole.home {
	tls internal
	redir / /admin 302
	reverse_proxy pihole:80
}
abs.home {
	tls internal
	reverse_proxy audiobookshelf:80
}
home.home, homelab {
	tls internal
	reverse_proxy homepage:3000
}
CADDY
cat > compose.yaml <<'YAML'
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
YAML
docker compose up -d
sleep 4
docker exec caddy cat /data/caddy/pki/authorities/local/root.crt > ~/proxy/caddy-root-ca.crt 2>/dev/null \
  && echo "Exported ~/proxy/caddy-root-ca.crt (trust it on your devices)." || echo "CA not ready yet; re-run this line shortly."
