#!/usr/bin/env bash
# Generates webapp traffic with ~10% server errors, to exercise LogQL dashboards and the 5xx log alert
set -euo pipefail
URL=http://127.0.0.1:8080
N=${1:-600}
for i in $(seq 1 "$N"); do
  r=$((RANDOM % 10))
  if   (( r == 0 )); then curl -s -o /dev/null "$URL/error"
  elif (( r == 1 )); then curl -s -o /dev/null "$URL/missing-page"
  else                    curl -s -o /dev/null "$URL/"
  fi
  sleep 0.2
done
echo "sent $N requests"
