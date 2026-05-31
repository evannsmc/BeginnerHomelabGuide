#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Heads up: this script automates MY homelab, for MY use case (see the repo
# README). It's a worked example to read and adapt, not a one-size-fits-all
# installer. Read it before you run it, and change anything that doesn't fit
# your hardware, your services, or what you actually need.
# ---------------------------------------------------------------------------
# Part 3 — Pi-hole network-wide ad blocking. Run this ON the Pi.
#
# Frees port 53 (disables the systemd-resolved stub), then deploys Pi-hole as a
# Compose project in ~/pihole with secrets kept in a gitignored .env. This is the
# "home network" layout (bound to the Pi's LAN IP); Part 4 widens it to the
# tailnet. Pointing your ROUTER's DNS at the Pi is a manual step (printed below).
set -euo pipefail

echo "==> Freeing port 53 — disabling the systemd-resolved stub listener"
sudo mkdir -p /etc/systemd/resolved.conf.d
printf '[Resolve]\nDNSStubListener=no\n' | sudo tee /etc/systemd/resolved.conf.d/no-stub.conf >/dev/null
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
if sudo ss -tulpn 2>/dev/null | grep -q ':53 .*systemd-resolve'; then
  echo "    !! stub still bound on :53 — check the drop-in and re-run"
else
  echo "    port 53 is free"
fi

mkdir -p ~/pihole
cd ~/pihole

if [ -f .env ]; then
  echo "==> ~/pihole/.env exists — keeping your existing settings/password"
else
  echo "==> Creating ~/pihole/.env"
  read -rp "    Timezone [America/Denver]: " TZIN; TZIN=${TZIN:-America/Denver}
  DEF_IP=$(hostname -I | awk '{print $1}')
  read -rp "    Pi LAN IP [$DEF_IP]: " IPIN; IPIN=${IPIN:-$DEF_IP}
  read -rsp "    Pi-hole admin password (blank = generate a strong one): " PWIN; echo
  PWIN=${PWIN:-$(openssl rand -base64 18)}
  ( umask 177; cat > .env <<EOF
TZ=$TZIN
PIHOLE_PASSWORD=$PWIN
PIHOLE_IP=$IPIN
EOF
  )
  echo "    wrote ~/pihole/.env (mode 600). Recover the password later with: cat ~/pihole/.env"
fi

# compose.yaml holds NO secret — only a ${PIHOLE_PASSWORD} reference from .env
cat > compose.yaml <<'YAML'
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest

    ports:
      - "${PIHOLE_IP}:53:53/tcp"
      - "${PIHOLE_IP}:53:53/udp"
      - "${PIHOLE_IP}:80:80/tcp"

    environment:
      TZ: "${TZ}"
      FTLCONF_webserver_api_password: "${PIHOLE_PASSWORD:?set PIHOLE_PASSWORD in .env}"
      FTLCONF_dns_upstreams: "1.1.1.1;1.0.0.1"
      FTLCONF_dns_listeningMode: "ALL"

    volumes:
      - ./etc-pihole:/etc/pihole

    restart: unless-stopped
YAML

cat > .gitignore <<'EOF'
.env
etc-pihole/
EOF

echo "==> Starting Pi-hole"
docker compose up -d
docker compose logs --tail 10 || true

PI_IP=$(grep '^PIHOLE_IP=' .env | cut -d= -f2-)
echo
echo "==> Pi-hole admin: http://$PI_IP/admin   (log in with the password from .env)"
cat <<NOTE

================================ MANUAL STEPS ================================
Point your home network at Pi-hole (covers every device, no per-device setup):
  - In your router: assign the Pi a DHCP reservation so $PI_IP never changes.
  - Set the router's PRIMARY DNS to $PI_IP. Leave the SECONDARY DNS BLANK
    (a secondary lets devices bypass Pi-hole and you'll see ads "randomly").
  - Renew leases (reboot router, or toggle Wi-Fi off/on per device).
Optional: in the UI -> Lists, add https://big.oisd.nl, then Tools -> Update Gravity.
=============================================================================
NOTE
