#!/usr/bin/env bash
# Install LocalSend + KDE Connect and open their firewall ports (run on your LINUX laptop). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail

command -v flatpak >/dev/null 2>&1 && flatpak install -y flathub org.localsend.localsend_app || true
if command -v apt >/dev/null 2>&1; then sudo apt install -y kdeconnect
elif command -v pacman >/dev/null 2>&1; then sudo pacman -S --noconfirm kdeconnect; fi
if command -v ufw >/dev/null 2>&1; then
  sudo ufw allow 53317/udp; sudo ufw allow 53317/tcp
  sudo ufw allow 1714:1764/udp; sudo ufw allow 1714:1764/tcp
fi
echo "Installed. Pair the apps on the same Wi-Fi; away from home, add devices by Tailscale IP."
