#!/usr/bin/env bash
# Add the home.home / homelab route to ~/caddy/Caddyfile and reload Caddy.
set -euo pipefail

if [ ! -f ~/caddy/Caddyfile ]; then
  echo "Missing ~/caddy/Caddyfile. Finish Chapter 4 first." >&2
  exit 1
fi

if ! grep -q '^home\.home, homelab {' ~/caddy/Caddyfile; then
  cat >> ~/caddy/Caddyfile <<'EOF'

home.home, homelab {
	tls internal
	reverse_proxy homepage:3000
}
EOF
fi

( cd ~/caddy && docker compose restart caddy )
echo "Added the dashboard route and restarted Caddy."
