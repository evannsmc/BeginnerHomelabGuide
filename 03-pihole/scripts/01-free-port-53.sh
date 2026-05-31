#!/usr/bin/env bash
# Disable the systemd-resolved stub so Pi-hole can use port 53 (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
set -euo pipefail

sudo mkdir -p /etc/systemd/resolved.conf.d
printf '[Resolve]\nDNSStubListener=no\n' | sudo tee /etc/systemd/resolved.conf.d/no-stub.conf >/dev/null
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
sudo ss -tulpn 2>/dev/null | grep ':53 ' && echo "something still on :53" || echo "port 53 is free"
