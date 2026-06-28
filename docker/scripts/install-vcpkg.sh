#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${VCPKG_REF:?VCPKG_REF is required}"
: "${VCPKG_ROOT:=/opt/vcpkg}"
: "${VCPKG_DOWNLOADS:=/opt/vcpkg-downloads}"

export VCPKG_DISABLE_METRICS=1

mkdir -p "${VCPKG_DOWNLOADS}"

if [[ -e "${VCPKG_ROOT}" && ! -x "${VCPKG_ROOT}/vcpkg" ]]; then
  die "${VCPKG_ROOT} exists but does not contain a bootstrapped vcpkg binary"
fi

if [[ ! -x "${VCPKG_ROOT}/vcpkg" ]]; then
  rm -rf "${VCPKG_ROOT}"
  log "Cloning vcpkg ${VCPKG_REF}"
  git -c advice.detachedHead=false clone --depth 1 --branch "${VCPKG_REF}" https://github.com/microsoft/vcpkg.git "${VCPKG_ROOT}"
  "${VCPKG_ROOT}/bootstrap-vcpkg.sh" -disableMetrics
fi

ln -sf "${VCPKG_ROOT}/vcpkg" /usr/local/bin/vcpkg

rm -rf \
  "${VCPKG_ROOT}/.git" \
  "${VCPKG_ROOT}/buildtrees" \
  "${VCPKG_ROOT}/downloads" \
  "${VCPKG_ROOT}/packages" \
  "${VCPKG_ROOT}/.cache"
find "${VCPKG_DOWNLOADS}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

chmod -R a+rwX "${VCPKG_ROOT}" "${VCPKG_DOWNLOADS}"

vcpkg version
clean_caches
