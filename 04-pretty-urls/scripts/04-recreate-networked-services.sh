#!/usr/bin/env bash
# Recreate Audiobookshelf and Pi-hole so their updated compose files take effect.
set -euo pipefail

( cd ~/audiobookshelf && docker compose up -d --force-recreate )
( cd ~/pihole && docker compose up -d --force-recreate )
echo "Pi-hole + Audiobookshelf are on the homelab network; Pi-hole web is now on :8081."
