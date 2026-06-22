#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${DEBUG_TOOLCHAIN:?DEBUG_TOOLCHAIN must be gcc or clang}"

packages=(
  linux-perf
)

case "${DEBUG_TOOLCHAIN}" in
  gcc)
    packages+=(gdb)
    ;;
  clang)
    : "${LLVM_MAJOR:=19}"
    packages+=("lldb-${LLVM_MAJOR}")
    ;;
  *)
    die "unsupported DEBUG_TOOLCHAIN: ${DEBUG_TOOLCHAIN}"
    ;;
esac

apt_install "${packages[@]}"

if [[ "${DEBUG_TOOLCHAIN}" == "clang" ]]; then
  update-alternatives --install /usr/bin/lldb lldb "/usr/bin/lldb-${LLVM_MAJOR}" 100
fi

clean_caches
