#!/bin/bash
set -euo pipefail

NGINX_PID=""
TTYD_PID=""

shutdown() {
  if [ -n "${NGINX_PID}" ] && kill -0 "${NGINX_PID}" >/dev/null 2>&1; then
    kill -TERM "${NGINX_PID}" >/dev/null 2>&1 || true
    wait "${NGINX_PID}" 2>/dev/null || true
  fi

  if [ -n "${TTYD_PID}" ] && kill -0 "${TTYD_PID}" >/dev/null 2>&1; then
    kill -TERM "${TTYD_PID}" >/dev/null 2>&1 || true
    wait "${TTYD_PID}" 2>/dev/null || true
  fi
}

trap shutdown INT TERM

if [ "${ENABLE_TERMINAL:-true}" = "true" ]; then
  echo "Starting web terminal on internal port 7681"
  ttyd -W -i 127.0.0.1 -p 7681 -b /terminal bash -l &
  TTYD_PID=$!
fi

echo "Starting ingress nginx on port 9119"
nginx -g 'daemon off;' &
NGINX_PID=$!

echo "Starting Hermes gateway with dashboard on internal port 9120"
exec hermes gateway run
