#!/usr/bin/env bash
# Pushes a synthetic alert straight into Alertmanager to test routing/notifications end to end
set -euo pipefail
SEV=${1:-warning}
curl -s -XPOST http://127.0.0.1:9093/api/v2/alerts -H 'Content-Type: application/json' -d "[{
  \"labels\": {\"alertname\": \"TestAlert\", \"severity\": \"$SEV\", \"instance\": \"vps-lab\"},
  \"annotations\": {\"summary\": \"Test alert ($SEV)\", \"description\": \"Manual test of Alertmanager routing.\"},
  \"endsAt\": \"$(date -u -d '+5 min' +%Y-%m-%dT%H:%M:%SZ)\"
}]" && echo "sent $SEV test alert"
