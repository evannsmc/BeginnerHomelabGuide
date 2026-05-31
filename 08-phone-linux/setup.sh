#!/usr/bin/env bash
# Part 8 — Phone <-> Linux file/clipboard sharing. Run this on your LINUX LAPTOP
# (NOT the headless Pi — these are desktop tools). Installs LocalSend + KDE
# Connect and opens the LAN firewall ports. Pairing happens in the apps.
set -euo pipefail

echo "==> LocalSend (Flatpak, if available)"
if command -v flatpak >/dev/null 2>&1; then
  flatpak install -y flathub org.localsend.localsend_app || \
    echo "    (skip — install the AppImage from localsend.org instead)"
else
  echo "    flatpak not found — grab the AppImage from https://localsend.org"
fi

echo "==> KDE Connect (distro package)"
if command -v apt >/dev/null 2>&1; then
  sudo apt install -y kdeconnect
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --noconfirm kdeconnect
else
  echo "    install 'kdeconnect' from your distro's package manager"
fi

if command -v ufw >/dev/null 2>&1; then
  echo "==> Opening firewall ports (ufw)"
  sudo ufw allow 53317/udp; sudo ufw allow 53317/tcp     # LocalSend
  sudo ufw allow 1714:1764/udp; sudo ufw allow 1714:1764/tcp  # KDE Connect
fi

cat <<'NOTE'

NEXT (on the iPhone): install LocalSend + KDE Connect from the App Store.
  - Same Wi-Fi: devices auto-discover. In KDE Connect, accept the pairing
    request on the desktop.
  - Away from home: add the device by its Tailscale IP (100.x.y.z) manually —
    LocalSend favorite / KDE Connect "Add device by IP" — port 53317 for LocalSend.
Note: on iOS, KDE Connect does clipboard + battery + files; notification/SMS
mirroring is Android-only.
NOTE
