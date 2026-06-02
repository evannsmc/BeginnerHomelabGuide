#!/usr/bin/env bash
# Start Audiobookshelf from the compose file created by 02-create-compose.sh.
set -euo pipefail

if [ ! -f ~/audiobookshelf/compose.yaml ]; then
  echo "Missing ~/audiobookshelf/compose.yaml. Run 02-create-compose.sh first." >&2
  exit 1
fi

( cd ~/audiobookshelf && docker compose up -d )
echo "Audiobookshelf is on http://<pi>:13378 (library content goes in ./media/Audiobooks)."
