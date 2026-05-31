#!/usr/bin/env bash
# Advertise this Pi as a Tailscale exit node (run on the Pi; approve in the admin console). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
set -euo pipefail

printf 'net.ipv4.ip_forward=1\nnet.ipv6.conf.all.forwarding=1\n' | sudo tee /etc/sysctl.d/99-tailscale.conf >/dev/null
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
sudo tailscale set --advertise-exit-node
echo "Approve it: admin console -> Machines -> this Pi -> Edit route settings -> Use as exit node."
