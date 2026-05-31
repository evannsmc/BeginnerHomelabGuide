#!/usr/bin/env bash
# Install ../compose/compose.yaml and start Audiobookshelf (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; C="$SD/../compose"

# Folders are created by 01-make-dirs.sh; this only needs the project dir to exist.
mkdir -p ~/audiobookshelf
cp "$C/compose.yaml" ~/audiobookshelf/compose.yaml
printf 'config/\nmetadata/\nmedia/\n' > ~/audiobookshelf/.gitignore
( cd ~/audiobookshelf && docker compose up -d )
echo "Audiobookshelf is on http://<pi>:13378 (library content goes in ./media/Audiobooks)"
