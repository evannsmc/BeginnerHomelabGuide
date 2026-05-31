#!/usr/bin/env bash
# Create the self-contained Audiobookshelf folders (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

mkdir -p ~/audiobookshelf/config ~/audiobookshelf/metadata ~/audiobookshelf/media/Audiobooks
echo "Created ~/audiobookshelf/{config,metadata,media/Audiobooks}"
echo "(Add ~/audiobookshelf/media/Podcasts later for a podcast library.)"
