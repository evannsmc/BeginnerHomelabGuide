#!/usr/bin/env bash
# Create ~/caddy/Caddyfile.
set -euo pipefail

mkdir -p ~/caddy
cat > ~/caddy/Caddyfile <<'EOF'
# tls internal: Caddy makes its own private CA and serves HTTPS for .home names.
pihole.home {
	tls internal
	redir / /admin 302
	reverse_proxy pihole:80
}
abs.home {
	tls internal
	reverse_proxy audiobookshelf:80
}
EOF
echo "Wrote ~/caddy/Caddyfile."
