#!/usr/bin/env bash
# Copy the repo to /opt, install systemd units and start the stack
source "$(dirname "$0")/lib.sh"; require_root
REPO="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "$REPO" != "$STACK_DIR" ]]; then
  install -d "$STACK_DIR"
  cp -a "$REPO"/. "$STACK_DIR"/
fi
cd "$STACK_DIR"
[[ -f .env ]] || { cp .env.example .env; echo "Edit $STACK_DIR/.env, then re-run"; exit 1; }
chmod 600 .env
chown -R "$ADMIN_USER:$ADMIN_USER" "$STACK_DIR"
chmod +x scripts/*.sh

install -m 644 host/systemd/monitoring-stack.service      /etc/systemd/system/
install -m 644 host/systemd/monitoring-healthcheck.service /etc/systemd/system/
install -m 644 host/systemd/monitoring-healthcheck.timer   /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now monitoring-stack.service
systemctl enable --now monitoring-healthcheck.timer

sleep 20
docker compose ps
systemctl list-timers monitoring-healthcheck.timer --no-pager
