#!/usr/bin/env bash
# Checks each published endpoint; logs to /var/log/monitoring-lab/healthcheck.log.
# A non-zero exit marks the systemd unit as failed -> node_exporter -> SystemdUnitFailed alert.
set -uo pipefail
LOG=/var/log/monitoring-lab/healthcheck.log
declare -A ENDPOINTS=(
  [prometheus]=http://127.0.0.1:9090/-/healthy
  [alertmanager]=http://127.0.0.1:9093/-/healthy
  [loki]=http://127.0.0.1:3100/ready
  [grafana]=http://127.0.0.1:3000/api/health
  [webapp]=http://127.0.0.1:8080/healthz
)
fail=0
for name in "${!ENDPOINTS[@]}"; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "${ENDPOINTS[$name]}")
  if [[ "$code" == "200" ]]; then status=OK; else status=FAIL; fail=1; fi
  echo "$(date -Is) level=$([[ $status == OK ]] && echo info || echo error) service=$name status=$status http_code=$code" >> "$LOG"
done
exit $fail
