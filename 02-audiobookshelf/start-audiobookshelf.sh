#!/usr/bin/env bash
# Write the Audiobookshelf compose file and start the container (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

docker network create homelab 2>/dev/null || true
mkdir -p ~/audiobookshelf/config ~/audiobookshelf/metadata ~/audiobookshelf/media/Audiobooks
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
    networks:
      - homelab
    restart: unless-stopped
networks:
  homelab:
    external: true
YAML
printf 'config/\nmetadata/\nmedia/\n' > .gitignore
docker compose up -d
echo "Audiobookshelf is on http://<pi>:13378 (library content goes in ./media/Audiobooks)"
