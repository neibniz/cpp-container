#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${LLVM_MAJOR:=22}"

apt_install "clangd-${LLVM_MAJOR}"

update-alternatives --install /usr/bin/clangd clangd "/usr/bin/clangd-${LLVM_MAJOR}" 100

clangd --version
clean_caches
