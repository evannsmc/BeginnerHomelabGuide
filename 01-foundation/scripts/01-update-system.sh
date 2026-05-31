#!/usr/bin/env bash
# Update the base system (run on the Pi). Small self-contained helper; this is the setup I use and test, adapt as needed.
set -euo pipefail
set -euo pipefail

sudo apt update && sudo apt upgrade -y
