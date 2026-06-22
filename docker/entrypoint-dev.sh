#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$#" -gt 0 ]]; then
  exec "$@"
fi

mkdir -p /run/sshd
ssh-keygen -A >/dev/null 2>&1 || true
exec /usr/sbin/sshd -D -e
