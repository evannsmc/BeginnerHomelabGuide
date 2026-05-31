#!/usr/bin/env bash
# Create the homelab network and install the networked composes for Pi-hole + Audiobookshelf (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; C="$SD/../compose"

docker network create homelab 2>/dev/null || true
cp "$C/audiobookshelf.compose.yaml" ~/audiobookshelf/compose.yaml
( cd ~/audiobookshelf && docker compose up -d --force-recreate )
cp "$C/pihole.compose.yaml" ~/pihole/compose.yaml
( cd ~/pihole && docker compose up -d --force-recreate )
echo "Pi-hole + Audiobookshelf are on the homelab network; Pi-hole web is now on :8081."
