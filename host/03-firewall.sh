#!/usr/bin/env bash
# UFW: deny inbound by default, allow SSH (rate limited), optionally Grafana.
# NOTE: Docker-published ports bypass UFW (Docker writes its own iptables rules),
# which is why every stack port except Grafana is bound to 127.0.0.1 in docker-compose.yml.
source "$(dirname "$0")/lib.sh"; require_root

apt-get install -y -qq ufw
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw limit "$SSH_PORT/tcp" comment 'SSH (rate limited)'
if [[ "${GRAFANA_PUBLIC:-0}" == "1" ]]; then
  ufw allow 3000/tcp comment 'Grafana'
fi
ufw logging low
ufw --force enable
ufw status verbose
