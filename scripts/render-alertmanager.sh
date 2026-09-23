#!/usr/bin/env bash
# Render alertmanager.yml from the template, injecting secrets from .env
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
: "${TELEGRAM_BOT_TOKEN:?missing in .env}" "${TELEGRAM_CHAT_ID:?missing in .env}"
envsubst '${TELEGRAM_BOT_TOKEN} ${TELEGRAM_CHAT_ID}' \
  < alertmanager/alertmanager.yml.tmpl > alertmanager/alertmanager.yml
chmod 644 alertmanager/alertmanager.yml   # read by the container's nobody user
