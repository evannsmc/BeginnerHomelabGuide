#!/usr/bin/env bash
# Deploy Audiobookshelf from this folder's compose.yaml (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Folders come from make-dirs.sh; run that first. This installs the compose file
# (the same one shown in this chapter) and starts the container. No homelab
# network yet, that's Chapter 4.
cp "$SD/compose.yaml" ~/audiobookshelf/compose.yaml
printf 'config/\nmetadata/\nmedia/\n' > ~/audiobookshelf/.gitignore
( cd ~/audiobookshelf && docker compose up -d )
echo "Audiobookshelf is on http://<pi>:13378 (library content goes in ./media/Audiobooks)"
