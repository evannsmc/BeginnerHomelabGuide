#!/usr/bin/env bash
# Create the homelab network and put Pi-hole + Audiobookshelf on it, from this folder's composes (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Chapter 4, Steps 1-2: create the shared network, then install the post-Chapter-4
# (networked) compose files for Audiobookshelf and Pi-hole and recreate them.
docker network create homelab 2>/dev/null || true
cp "$SD/audiobookshelf.compose.yaml" ~/audiobookshelf/compose.yaml
( cd ~/audiobookshelf && docker compose up -d --force-recreate )
cp "$SD/pihole.compose.yaml" ~/pihole/compose.yaml
( cd ~/pihole && docker compose up -d --force-recreate )
echo "Pi-hole + Audiobookshelf are on the homelab network; Pi-hole web is now on :8081."
