#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${GCC_MAJOR:=14}"

apt_install \
  "gcc-${GCC_MAJOR}" \
  "g++-${GCC_MAJOR}" \
  libasan8 \
  liblsan0 \
  libtsan2 \
  libubsan1
update-alternatives --install /usr/bin/gcc gcc "/usr/bin/gcc-${GCC_MAJOR}" 100
update-alternatives --install /usr/bin/g++ g++ "/usr/bin/g++-${GCC_MAJOR}" 100
update-alternatives --install /usr/bin/cc cc "/usr/bin/gcc-${GCC_MAJOR}" 100
update-alternatives --install /usr/bin/c++ c++ "/usr/bin/g++-${GCC_MAJOR}" 100

gcc --version
g++ --version
clean_caches
