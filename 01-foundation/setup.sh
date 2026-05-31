#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Heads up: this script automates MY homelab, for MY use case (see the repo
# README). It's a worked example to read and adapt, not a one-size-fits-all
# installer. Read it before you run it, and change anything that doesn't fit
# your hardware, your services, or what you actually need.
# ---------------------------------------------------------------------------
# Part 1 — Foundation: Docker + Tailscale on a freshly-flashed Raspberry Pi.
#
# Run this ON the Pi, after you've flashed Raspberry Pi OS Lite (64-bit) with
# Raspberry Pi Imager and enabled key-only SSH. It installs Docker and Tailscale
# and brings the Pi onto your tailnet. The flashing and the admin-console steps
# can't be scripted — they're printed at the end.
set -euo pipefail

echo "==> Updating the base system (apt update && upgrade)"
sudo apt update && sudo apt upgrade -y

if command -v docker >/dev/null 2>&1; then
  echo "==> Docker already installed — skipping"
else
  echo "==> Installing Docker (official one-line installer)"
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
  echo "    Added $USER to the docker group — run 'newgrp docker' or re-login"
fi

if command -v tailscale >/dev/null 2>&1; then
  echo "==> Tailscale already installed — skipping"
else
  echo "==> Installing Tailscale"
  curl -fsSL https://tailscale.com/install.sh | sh
fi

echo "==> Bringing Tailscale up — a sign-in URL will print; open it and sign in"
sudo tailscale up

echo
echo "    This Pi's Tailscale IP: $(tailscale ip -4 2>/dev/null | head -1 || echo '(run: tailscale ip -4)')"
echo

cat <<'NOTE'
================================ MANUAL STEPS ================================
These can't be scripted:

1. Flash the SD card with Raspberry Pi Imager:
     - OS:  "Ubuntu Server 26.04 LTS (64-bit)" (Other general-purpose OS ->
            Ubuntu) — the reference build. "Raspberry Pi OS Lite (64-bit)" works
            identically; pick either, both are headless.
     - Settings (gear): set hostname "homelab" + your username; under Services
       enable SSH -> "Allow public-key authentication only" and paste your
       laptop's ~/.ssh/id_ed25519.pub  (generate with: ssh-keygen -t ed25519)

2. Tailscale admin console (https://login.tailscale.com):
     - DNS page:      confirm MagicDNS is enabled; note your tailnet name.
     - Machines page: rename this Pi to "homelab".

3. Install Tailscale on your laptop and phone, signed into the SAME account.
=============================================================================
NOTE
