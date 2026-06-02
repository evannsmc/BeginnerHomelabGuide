#!/usr/bin/env bash
# Replace ~/audiobookshelf/compose.yaml with the Chapter 4 networked version.
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
      - ./media/Audiobooks:/audiobooks
      - ./config:/config
      - ./metadata:/metadata
    networks:
      - homelab
    restart: unless-stopped
networks:
  homelab:
    external: true
EOF
echo "Wrote ~/audiobookshelf/compose.yaml with the homelab network attached."
