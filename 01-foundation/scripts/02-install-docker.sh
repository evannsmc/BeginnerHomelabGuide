#!/usr/bin/env bash
# Install Docker + add yourself to the docker group (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
set -euo pipefail

if command -v docker >/dev/null 2>&1; then echo "Docker already installed."; exit 0; fi
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"
echo "Added $USER to the docker group. Run 'newgrp docker' or log out and back in."
