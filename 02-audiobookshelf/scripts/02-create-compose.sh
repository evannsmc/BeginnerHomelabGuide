#!/usr/bin/env bash
# Create ~/audiobookshelf/compose.yaml.
set -euo pipefail

mkdir -p ~/audiobookshelf
cat > ~/audiobookshelf/compose.yaml <<'EOF'
services:
  audiobookshelf:
    container_name: audiobookshelf
    image: ghcr.io/advplyr/audiobookshelf:latest
    ports:
      - "13378:80"
    volumes:
      - ./media/Audiobooks:/audiobooks    # add ./media/Podcasts:/podcasts later
      - ./config:/config
      - ./metadata:/metadata
    restart: unless-stopped
EOF
printf 'config/\nmetadata/\nmedia/\n' > ~/audiobookshelf/.gitignore
echo "Wrote ~/audiobookshelf/compose.yaml and ~/audiobookshelf/.gitignore."
