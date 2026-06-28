#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

apt_install \
  ca-certificates \
  curl \
  file \
  gawk \
  git \
  iproute2 \
  make \
  net-tools \
  ninja-build \
  pkg-config \
  procps \
  tar \
  unzip \
  xz-utils \
  zip

clean_caches
