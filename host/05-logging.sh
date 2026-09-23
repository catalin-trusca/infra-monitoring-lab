#!/usr/bin/env bash
# Persistent journald (needed by Promtail's journal scraper) + logrotate for lab logs
source "$(dirname "$0")/lib.sh"; require_root
apt-get install -y -qq logrotate
HERE="$(cd "$(dirname "$0")" && pwd)"

install -d /etc/systemd/journald.conf.d /var/log/journal
install -m 644 "$HERE/config/journald.conf" /etc/systemd/journald.conf.d/10-persistent.conf
systemd-tmpfiles --create --prefix /var/log/journal
systemctl restart systemd-journald
log "journald persistent: $(journalctl --disk-usage)"

install -d -m 750 -o root -g adm /var/log/monitoring-lab
install -m 644 "$HERE/config/logrotate-monitoring-lab" /etc/logrotate.d/monitoring-lab
logrotate --debug /etc/logrotate.d/monitoring-lab 2>&1 | tail -n 5
log "logrotate config installed (dry-run above)."
