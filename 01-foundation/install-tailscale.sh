#!/usr/bin/env bash
# Install Tailscale and bring it up (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

command -v tailscale >/dev/null 2>&1 || curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up    # opens a sign-in URL
tailscale ip -4 2>/dev/null | head -1
