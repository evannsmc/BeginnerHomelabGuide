#!/usr/bin/env bash
# Part 2 — Audiobookshelf media server (Docker Compose). Run this ON the Pi.
#
# Creates a self-contained ~/audiobookshelf Compose project and launches it.
# Ripping a disc and copying audio to ~/Audiobooks is done from your laptop (see
# this section's README, Steps 3-4) — the server happily serves an empty folder
# until then.
set -euo pipefail

echo "==> Creating audio + project folders"
mkdir -p ~/Audiobooks ~/Audiobooks-drill
mkdir -p ~/audiobookshelf/config ~/audiobookshelf/metadata
cd ~/audiobookshelf

# If an old (pre-Compose) container is hanging around, drop it — data lives in
# the bind mounts below, so nothing is lost.
if docker ps -a --format '{{.Names}}' | grep -qx audiobookshelf; then
  if [ -z "$(docker inspect audiobookshelf --format '{{index .Config.Labels "com.docker.compose.project"}}')" ]; then
    echo "==> Removing a non-Compose 'audiobookshelf' container"
    docker rm -f audiobookshelf
  fi
fi

echo "==> Writing ~/audiobookshelf/compose.yaml"
cat > compose.yaml <<'EOF'
services:
  audiobookshelf:
    container_name: audiobookshelf
    image: ghcr.io/advplyr/audiobookshelf:latest

    ports:
      - "13378:80"          # host 13378 -> container 80 (host 80 stays free for Caddy)

    volumes:
      - ${HOME}/Audiobooks:/audiobooks
      - ${HOME}/Audiobooks-drill:/audiobooks-drill
      - ./config:/config
      - ./metadata:/metadata

    restart: unless-stopped
EOF
printf 'config/\nmetadata/\n' > .gitignore

echo "==> Starting Audiobookshelf"
docker compose up -d

echo
echo "==> Up. Open http://homelab:13378 (or http://<pi-ip>:13378) to:"
echo "      - create the admin user"
echo "      - add a 'Books' library pointing at the container path /audiobooks"
echo
cat <<'NOTE'
MANUAL (from your laptop): rip your audio, then copy it to the Pi, e.g.
  rsync -avz --progress --partial --no-perms ~/Audiobooks/ you@homelab:~/Audiobooks/
Then click "Scan Library" in the web UI. See this section's README for detail.
NOTE
