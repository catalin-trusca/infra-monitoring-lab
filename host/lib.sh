#!/usr/bin/env bash
# Shared settings for host provisioning scripts (Ubuntu 22.04 / 24.04)
set -euo pipefail
ADMIN_USER="${ADMIN_USER:-ops}"
SSH_PORT="${SSH_PORT:-22}"
STACK_DIR="${STACK_DIR:-/opt/monitoring-lab}"
log() { echo -e "\e[1;32m[+]\e[0m $*"; }
require_root() { [[ $EUID -eq 0 ]] || { echo "Run as root (sudo)"; exit 1; }; }
