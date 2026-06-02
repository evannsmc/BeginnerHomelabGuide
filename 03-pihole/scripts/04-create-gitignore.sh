#!/usr/bin/env bash
# Keep the Pi-hole .env and runtime data out of Git.
set -euo pipefail

mkdir -p ~/pihole
printf '.env\netc-pihole/\n' > ~/pihole/.gitignore
echo "Wrote ~/pihole/.gitignore."
