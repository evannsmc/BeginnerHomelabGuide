#!/usr/bin/env bash
# Part 7 — On the road. Nothing to install: this part is the mental model for
# what you can/can't have away from home. This script just prints the rule, the
# decision matrix, and the client commands. (Full explanation in the README.)
set -euo pipefail

cat <<'EOF'
================================ THE ONE RULE ================================
A full-device VPN owns the default route AND the DNS, and a phone runs ONLY ONE
VPN at a time. So homelab access, Pi-hole filtering, and a privacy VPN cannot
all be on at once — you switch between coherent modes.

DECISION MATRIX (away from home):
  Mode                                  Homelab  Pi-hole   Hides IP
  ----------------------------------------------------------------------------
  Tailscale on, no exit node (default)    yes      yes        no
  Tailscale + your Pi as exit node        yes      yes        no (home IP)
  Tailscale + Mullvad exit node           yes      no*        yes      *Mullvad DNS
  Aura / any standalone VPN on            no       no         yes

USEFUL CLIENT COMMANDS:
  tailscale set --exit-node=<mullvad-node> --exit-node-allow-lan-access
  tailscale set --exit-node=          # turn the exit node off
=============================================================================
EOF
