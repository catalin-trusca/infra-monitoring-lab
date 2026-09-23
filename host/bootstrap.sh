#!/usr/bin/env bash
# Run everything in order. Usage: sudo ADMIN_USER=ops SSH_PORT=22 ./host/bootstrap.sh
set -euo pipefail
cd "$(dirname "$0")"
for s in 01-users.sh 02-ssh-hardening.sh 03-firewall.sh 04-docker.sh 05-logging.sh 06-install-stack.sh; do
  echo "=== $s ==="
  bash "$s"
done
