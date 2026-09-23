#!/usr/bin/env bash
# Docker Engine + Compose plugin from the official repository, with log rotation
source "$(dirname "$0")/lib.sh"; require_root

apt-get install -y -qq gettext-base   # envsubst, used by scripts/render-alertmanager.sh

if ! command -v docker &>/dev/null; then
  apt-get update -qq
  apt-get install -y -qq ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Default log rotation for every container
cat > /etc/docker/daemon.json <<'JSON'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "live-restore": true
}
JSON
systemctl enable docker
systemctl restart docker
usermod -aG docker "$ADMIN_USER"
log "Docker $(docker --version | cut -d' ' -f3) installed; $ADMIN_USER added to docker group (re-login needed)."
