#!/usr/bin/env bash
# Write the Audiobookshelf compose file and start the container (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

# Folders come from make-dirs.sh; run that first. This only writes the compose
# and starts the container. Joining the shared 'homelab' network happens in
# Chapter 4, not here.
cd ~/audiobookshelf
cat > compose.yaml <<'YAML'
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
YAML
printf 'config/\nmetadata/\nmedia/\n' > .gitignore
docker compose up -d
echo "Audiobookshelf is on http://<pi>:13378 (library content goes in ./media/Audiobooks)"
