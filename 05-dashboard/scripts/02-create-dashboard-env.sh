#!/usr/bin/env bash
# Create ~/dashboard/.env for Homepage widget secrets.
set -euo pipefail

mkdir -p ~/dashboard
if [ -f ~/dashboard/.env ]; then
  echo "~/dashboard/.env already exists; leaving it alone."
  exit 0
fi

PW=$(grep -h '^PIHOLE_PASSWORD=' ~/pihole/.env 2>/dev/null | cut -d= -f2- || true)
read -rp "Pi-hole password [$([ -n "$PW" ] && printf 'reuse from ~/pihole/.env' || printf 'blank')]: " PW_INPUT
PW=${PW_INPUT:-$PW}
read -rp "Audiobookshelf API token (blank OK): " TOK

( umask 177; printf 'PIHOLE_PASSWORD=%s\nABS_TOKEN=%s\n' "$PW" "$TOK" > ~/dashboard/.env )
printf '.env\n' > ~/dashboard/.gitignore
echo "Wrote ~/dashboard/.env (mode 600) and ~/dashboard/.gitignore."
