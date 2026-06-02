#!/usr/bin/env bash
# Point pihole.home and abs.home at the Pi's Tailscale IP.
set -euo pipefail

TSIP=$(tailscale ip -4 | head -1)
docker exec pihole pihole-FTL --config dns.hosts \
  "[ \"$TSIP pihole.home\", \"$TSIP abs.home\" ]"
echo "Added pihole.home / abs.home -> $TSIP"
