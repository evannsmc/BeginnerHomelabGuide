#!/usr/bin/env bash
# Create the Homepage config YAML files.
set -euo pipefail

mkdir -p ~/dashboard/config
rm -rf ~/dashboard/config
mkdir -p ~/dashboard/config
cat > ~/dashboard/config/settings.yaml <<'EOF'
title: My Homelab
theme: dark
color: slate
headerStyle: boxed
layout:
  Media:
    style: row
    columns: 2
  Network:
    style: row
    columns: 2
  Management:
    style: row
    columns: 2
  Links:
    style: row
    columns: 4
EOF

cat > ~/dashboard/config/docker.yaml <<'EOF'
my-docker:
  socket: /var/run/docker.sock
EOF

cat > ~/dashboard/config/services.yaml <<'EOF'
- Media:
    - Audiobookshelf:
        icon: audiobookshelf.png
        href: https://abs.home
        description: Audiobooks & language courses
        server: my-docker
        container: audiobookshelf
        widget:
          type: audiobookshelf
          url: http://audiobookshelf:80
          key: '{{HOMEPAGE_VAR_ABS_TOKEN}}'

- Network:
    - Pi-hole:
        icon: pi-hole.png
        href: https://pihole.home
        description: DNS ad-blocking
        server: my-docker
        container: pihole
        widget:
          type: pihole
          url: http://pihole:80
          version: 6
          key: '{{HOMEPAGE_VAR_PIHOLE_PASSWORD}}'

- Management:
    - Portainer:
        icon: portainer.png
        href: https://homelab:9443
        description: Manage Docker containers
EOF

cat > ~/dashboard/config/widgets.yaml <<'EOF'
- resources:
    cpu: true
    memory: true
    disk: /
- search:
    provider: duckduckgo
    target: _blank
- datetime:
    format:
      timeStyle: short
- greeting:
    text_size: xl
    text: Welcome to the homelab
EOF

cat > ~/dashboard/config/bookmarks.yaml <<'EOF'
- Links:
    - Tailscale admin:
        - abbr: TS
          href: https://login.tailscale.com/admin/machines
    - Router:
        - abbr: RT
          href: http://192.168.1.1
    - Pi-hole docs:
        - abbr: PH
          href: https://docs.pi-hole.net
    - Audiobookshelf docs:
        - abbr: AB
          href: https://www.audiobookshelf.org/docs
EOF
echo "Wrote ~/dashboard/config/*.yaml."
