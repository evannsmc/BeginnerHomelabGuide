#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Heads up: this script automates MY homelab, for MY use case (see the repo
# README). It's a worked example to read and adapt, not a one-size-fits-all
# installer. Read it before you run it, and change anything that doesn't fit
# your hardware, your services, or what you actually need.
# ---------------------------------------------------------------------------
# Part 6 — VPN options. Choosing a VPN is mostly a decision (read the README).
# The one thing scriptable HERE is Option C: make THIS Pi a Tailscale exit node
# ("appear at home", and the only exit option that keeps Pi-hole filtering).
# Run this ON the Pi. Mullvad (the recommended privacy option) is a client-side
# choice — the commands are printed at the end.
set -euo pipefail

echo "This part is mostly about choosing a VPN approach — see this section's README."
echo
read -rp "Advertise THIS Pi as a Tailscale exit node (Option C)? [y/N] " yn
if [[ "${yn:-N}" =~ ^[Yy] ]]; then
  echo "==> Enabling IP forwarding"
  printf 'net.ipv4.ip_forward=1\nnet.ipv6.conf.all.forwarding=1\n' \
    | sudo tee /etc/sysctl.d/99-tailscale.conf >/dev/null
  sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
  echo "==> Advertising this Pi as an exit node"
  sudo tailscale set --advertise-exit-node
  echo "    Approve it: admin console -> Machines -> this Pi -> Edit route"
  echo "    settings -> enable 'Use as exit node'."
else
  echo "Skipped."
fi

cat <<'NOTE'

For privacy / changing location (recommended: Tailscale's Mullvad add-on, ~$5/mo):
  1. Buy it: admin console -> Settings -> Mullvad -> Configure.
  2. On a CLIENT device:
       tailscale exit-node list                  # list Mullvad cities
       tailscale set --exit-node=<mullvad-node>  # route everything through it
       tailscale set --exit-node=                # turn it back off
On iOS/Android: the ... menu -> Use exit node -> pick a Mullvad location.
NOTE
