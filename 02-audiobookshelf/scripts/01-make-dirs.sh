#!/usr/bin/env bash
# Create the Audiobookshelf folders (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
set -euo pipefail

mkdir -p ~/audiobookshelf/config ~/audiobookshelf/metadata ~/audiobookshelf/media/Audiobooks
echo "Created ~/audiobookshelf/{config,metadata,media/Audiobooks}  (add media/Podcasts later)"
