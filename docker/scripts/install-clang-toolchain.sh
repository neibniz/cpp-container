#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${GCC_MAJOR:=14}"
: "${LLVM_MAJOR:=19}"

apt_install \
  "clang-${LLVM_MAJOR}" \
  "lld-${LLVM_MAJOR}" \
  "libclang-rt-${LLVM_MAJOR}-dev" \
  "libgcc-${GCC_MAJOR}-dev" \
  "libstdc++-${GCC_MAJOR}-dev"

update-alternatives --install /usr/bin/clang clang "/usr/bin/clang-${LLVM_MAJOR}" 100
update-alternatives --install /usr/bin/clang++ clang++ "/usr/bin/clang++-${LLVM_MAJOR}" 100
update-alternatives --install /usr/bin/ld.lld ld.lld "/usr/bin/ld.lld-${LLVM_MAJOR}" 100
update-alternatives --install /usr/bin/cc cc "/usr/bin/clang-${LLVM_MAJOR}" 90
update-alternatives --install /usr/bin/c++ c++ "/usr/bin/clang++-${LLVM_MAJOR}" 90

clang --version
clang++ --version
clean_caches
