#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

apt_install \
  ca-certificates \
  curl \
  git \
  patch \
  tar \
  unzip \
  xz-utils \
  zip \
  zstd

clean_caches
