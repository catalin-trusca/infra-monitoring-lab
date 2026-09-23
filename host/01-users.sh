#!/usr/bin/env bash
# Create a non-root admin user with key-based access and sudo
source "$(dirname "$0")/lib.sh"; require_root

if ! id "$ADMIN_USER" &>/dev/null; then
  adduser --disabled-password --gecos "" "$ADMIN_USER"
  log "Created user $ADMIN_USER"
fi
usermod -aG sudo "$ADMIN_USER"

# Reuse the key that was used to log in as root
install -d -m 700 -o "$ADMIN_USER" -g "$ADMIN_USER" "/home/$ADMIN_USER/.ssh"
if [[ -f /root/.ssh/authorized_keys ]]; then
  install -m 600 -o "$ADMIN_USER" -g "$ADMIN_USER" /root/.ssh/authorized_keys "/home/$ADMIN_USER/.ssh/authorized_keys"
  log "Copied authorized_keys to $ADMIN_USER"
fi

# Sudo requires a password: set one interactively
if ! passwd -S "$ADMIN_USER" | grep -q " P "; then
  log "Set a sudo password for $ADMIN_USER:"
  passwd "$ADMIN_USER"
fi

# Lock root password login (key login for root is disabled in sshd anyway)
passwd -l root
log "Users done. TEST in a new terminal: ssh $ADMIN_USER@<server> before continuing."
