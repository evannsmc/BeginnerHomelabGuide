#!/usr/bin/env bash
# Part 2 — Audiobookshelf media server. Run this ON the Pi (Docker from Part 1).
#
# It creates the storage folders and launches the container. Ripping a disc and
# copying audio to ~/Audiobooks is done from your laptop (see this section's
# README, Steps 3-4) — the server happily serves an empty folder until then.
set -euo pipefail

echo "==> Creating audio + config folders"
mkdir -p ~/Audiobooks ~/Audiobooks-drill
mkdir -p ~/.config/audiobookshelf/config ~/.config/audiobookshelf/metadata

if docker ps -a --format '{{.Names}}' | grep -qx audiobookshelf; then
  echo "==> Existing audiobookshelf container found — recreating"
  docker rm -f audiobookshelf
fi

echo "==> Starting Audiobookshelf on host port 13378"
docker run -d \
  --name audiobookshelf \
  --restart unless-stopped \
  -p 13378:80 \
  -v ~/Audiobooks:/audiobooks \
  -v ~/Audiobooks-drill:/audiobooks-drill \
  -v ~/.config/audiobookshelf/config:/config \
  -v ~/.config/audiobookshelf/metadata:/metadata \
  ghcr.io/advplyr/audiobookshelf:latest

# If the shared proxy network already exists (Part 4 done), re-attach so the
# pretty URL http://abs.home keeps working after this recreate.
if docker network inspect homelab >/dev/null 2>&1; then
  docker network connect homelab audiobookshelf 2>/dev/null || true
  echo "==> Re-attached to the 'homelab' network"
fi

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
