#!/usr/bin/env bash
# Point pihole.home / abs.home / home.home at the Pi's Tailscale IP in Pi-hole (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

TSIP=$(tailscale ip -4 | head -1)
docker exec pihole pihole-FTL --config dns.hosts \
  "[ \"$TSIP pihole.home\", \"$TSIP abs.home\", \"$TSIP home.home\" ]"
echo "Added pihole.home / abs.home / home.home -> $TSIP"
