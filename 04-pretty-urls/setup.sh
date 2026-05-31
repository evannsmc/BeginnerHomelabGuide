#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Heads up: this script automates MY homelab, for MY use case (see the repo
# README). It's a worked example to read and adapt, not a one-size-fits-all
# installer. Read it before you run it, and change anything that doesn't fit
# your hardware, your services, or what you actually need.
# ---------------------------------------------------------------------------
# Part 4 — Pretty URLs: Caddy reverse proxy (HTTPS) + Pi-hole local DNS. Run ON the Pi.
#
# Creates the shared 'homelab' network, attaches both Compose services
# (audiobookshelf + pihole) to it declaratively, widens Pi-hole onto the tailnet,
# deploys Caddy as the single front door with HTTPS via its own internal CA, adds
# the .home DNS records, and exports Caddy's root cert for you to trust on your
# devices. The Tailscale admin-console DNS push is manual (printed at the end).
set -euo pipefail

echo "==> Creating the shared 'homelab' Docker network"
docker network create homelab 2>/dev/null && echo "    created" || echo "    already exists"

echo "==> Attaching Audiobookshelf to homelab (declaratively, via its compose.yaml)"
cat > ~/audiobookshelf/compose.yaml <<'EOF'
services:
  audiobookshelf:
    container_name: audiobookshelf
    image: ghcr.io/advplyr/audiobookshelf:latest

    ports:
      - "13378:80"

    volumes:
      - ${HOME}/Audiobooks:/audiobooks
      - ${HOME}/Audiobooks-drill:/audiobooks-drill
      - ./config:/config
      - ./metadata:/metadata

    networks:
      - homelab            # NEW: join the shared proxy network

    restart: unless-stopped

networks:
  homelab:
    external: true         # NEW: the shared network created above
EOF
( cd ~/audiobookshelf && docker compose up -d --force-recreate )

echo "==> Rewriting ~/pihole/compose.yaml: all-interfaces + 8081 web + homelab network"
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
( cd ~/pihole && docker compose up -d --force-recreate )

echo "==> Deploying Caddy (~/proxy) with HTTPS via its internal CA"
mkdir -p ~/proxy
cat > ~/proxy/Caddyfile <<'CADDY'
# `tls internal` = Caddy issues each .home name a cert from its OWN local CA
# (no public CA issues certs for a private TLD). Trust that CA on your devices
# (printed below) and bare names like home.home open over HTTPS, no warning.
pihole.home {
	tls internal
	redir / /admin 302
	reverse_proxy pihole:80
}

abs.home {
	tls internal
	reverse_proxy audiobookshelf:80
}

# Pre-wired for Part 5's dashboard (homepage); harmless until Part 5 runs.
home.home, homelab {
	tls internal
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
( cd ~/proxy && docker compose up -d )
sleep 4

echo "==> Adding Pi-hole local DNS records -> the Pi's Tailscale IP"
TSIP=$(tailscale ip -4 | head -1)
docker exec pihole pihole-FTL --config dns.hosts \
  "[ \"$TSIP pihole.home\", \"$TSIP abs.home\", \"$TSIP home.home\" ]"
echo "    pihole.home / abs.home / home.home -> $TSIP"

echo "==> Exporting Caddy's root CA to ~/proxy/caddy-root-ca.crt (trust it on your devices)"
docker exec caddy cat /data/caddy/pki/authorities/local/root.crt > ~/proxy/caddy-root-ca.crt 2>/dev/null \
  && echo "    wrote ~/proxy/caddy-root-ca.crt" || echo "    (CA not ready yet; re-run this line shortly)"

cat <<NOTE

================================ MANUAL STEPS ================================
1. Make Pi-hole your tailnet's DNS (Tailscale admin console -> DNS page):
     - Add nameserver -> Custom: enter  $TSIP
         Restrict to domain: OFF      Use with exit node: OFF
     - Turn ON "Override local DNS".
   Then from any device:  ping home.home   (should answer from $TSIP)

2. Trust Caddy's root CA so bare names open with a padlock. Send the cert to your
   devices over the tailnet with Taildrop (run 'tailscale status' for peer names;
   if the Pi says "file access denied", run 'sudo tailscale set --operator=$USER'
   once, or send from your laptop):
     tailscale file cp ~/proxy/caddy-root-ca.crt <laptop-name>:
     tailscale file cp ~/proxy/caddy-root-ca.crt <iphone-name>:
   Then install it:
     - Linux:  sudo cp caddy-root-ca.crt /usr/local/share/ca-certificates/ \
               && sudo update-ca-certificates
               (Firefox: Settings -> Certificates -> Authorities -> Import)
     - iPhone: Tailscale app -> save the received .crt to Files -> open it ->
               install profile -> Settings -> General -> About -> Certificate
               Trust Settings -> Enable Full Trust.
============================================================================
NOTE
