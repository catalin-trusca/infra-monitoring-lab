#!/usr/bin/env bash
# Static validation of all configs using the tools shipped in the official images
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/render-alertmanager.sh
echo "== promtool check config =="
docker run --rm -v "$PWD/prometheus:/etc/prometheus:ro" --entrypoint promtool prom/prometheus:v2.53.2 \
  check config /etc/prometheus/prometheus.yml
echo "== amtool check-config =="
docker run --rm -v "$PWD/alertmanager:/etc/alertmanager:ro" --entrypoint amtool prom/alertmanager:v0.27.0 \
  check-config /etc/alertmanager/alertmanager.yml
echo "== loki -verify-config =="
docker run --rm -v "$PWD/loki:/etc/loki:ro" grafana/loki:3.1.1 \
  -config.file=/etc/loki/loki-config.yml -verify-config
echo "== docker compose config =="
docker compose config -q && echo "compose OK"
