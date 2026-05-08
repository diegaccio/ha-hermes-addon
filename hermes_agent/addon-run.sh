#!/bin/bash
set -euo pipefail

NGINX_PID=""

shutdown() {
  if [ -n "${NGINX_PID}" ] && kill -0 "${NGINX_PID}" >/dev/null 2>&1; then
    kill -TERM "${NGINX_PID}" >/dev/null 2>&1 || true
    wait "${NGINX_PID}" 2>/dev/null || true
  fi
}

trap shutdown INT TERM

echo "Starting ingress nginx on port 9119"
nginx -g 'daemon off;' &
NGINX_PID=$!

echo "Starting Hermes gateway with dashboard on internal port 9120"
exec hermes gateway run
