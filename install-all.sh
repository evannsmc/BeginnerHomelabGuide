#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Heads up: this script automates MY homelab, for MY use case (see the repo
# README). It's a worked example to read and adapt, not a one-size-fits-all
# installer. Read it before you run it, and change anything that doesn't fit
# your hardware, your services, or what you actually need.
# ---------------------------------------------------------------------------
# ============================================================================
# Beginner Homelab on a Raspberry Pi — one-shot installer.
#
# Run this ON the Pi (after Part 1's flashing + Tailscale sign-in). It runs the
# server buildout in order: Parts 1-5 (Docker/Tailscale, Audiobookshelf,
# Pi-hole, Caddy + pretty URLs, dashboard). It prompts for your timezone and
# passwords; nothing secret is hard-coded.
#
# Parts 6-8 (VPN, on-the-road, phone<->Linux) are optional and/or run on other
# machines, so they're left to you — see their READMEs / setup.sh.
#
# Safe to re-run: each step skips or recreates cleanly.
# ============================================================================
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PARTS=(01-foundation 02-audiobookshelf 03-pihole 04-pretty-urls 05-dashboard)

echo "This will build Parts 1-5 of the homelab on THIS machine."
echo "Make sure you're on the Raspberry Pi and Tailscale is signed in."
echo "These scripts automate MY homelab for MY use case (the Assimil-mp3 example);"
echo "read them first and adapt anything that does not fit your setup."
echo
read -rp "Continue? [y/N] " go
[[ "${go:-N}" =~ ^[Yy] ]] || { echo "Aborted."; exit 0; }

for part in "${PARTS[@]}"; do
  echo
  echo "############################################################"
  echo "#  $part"
  echo "############################################################"
  bash "$HERE/$part/setup.sh"
done

cat <<'DONE'

============================================================================
Core homelab is up (Parts 1-5). Two manual cloud/router steps remain:
  - Tailscale admin console -> DNS: add the Pi as a custom nameserver and turn
    on "Override local DNS"  (Part 4) — makes *.home + ad-blocking work on every
    device. Then test:  ping home.home
  - Router DNS -> point primary DNS at the Pi, secondary blank (Part 3) — for
    LAN devices that aren't on Tailscale.

Verify everything with the checklist in appendix-b-verify/README.md.
Optional next steps: 06-vpn, 07-away-from-home, 08-phone-linux.
============================================================================
DONE
