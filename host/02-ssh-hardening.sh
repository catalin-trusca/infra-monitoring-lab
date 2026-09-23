#!/usr/bin/env bash
# SSH hardening + fail2ban
source "$(dirname "$0")/lib.sh"; require_root
HERE="$(cd "$(dirname "$0")" && pwd)"

[[ -s "/home/$ADMIN_USER/.ssh/authorized_keys" ]] || { echo "No key for $ADMIN_USER, run 01-users.sh first"; exit 1; }

sed -e "s/__SSH_PORT__/$SSH_PORT/" -e "s/__ADMIN_USER__/$ADMIN_USER/" \
  "$HERE/config/10-hardening.conf" > /etc/ssh/sshd_config.d/10-hardening.conf
chmod 644 /etc/ssh/sshd_config.d/10-hardening.conf

sshd -t                      # abort (set -e) if the config is invalid
systemctl restart ssh
log "sshd hardened (port $SSH_PORT). Effective settings:"
sshd -T | grep -Ei '^(port|permitrootlogin|passwordauthentication|allowusers|maxauthtries) '

apt-get update -qq && apt-get install -y -qq fail2ban
sed "s/__SSH_PORT__/$SSH_PORT/" "$HERE/config/jail.local" > /etc/fail2ban/jail.local
systemctl enable --now fail2ban
systemctl restart fail2ban
log "fail2ban active:"; fail2ban-client status sshd
