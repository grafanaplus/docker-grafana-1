#!/bin/bash
set -e

if [[ "$1" = "grafana-server" ]]; then
    chown -R grafana.grafana /var/lib/grafana
    exec gosu grafana "$@"
else
    exec "$@"
fi
