#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${BUILDIFIER_VERSION:?BUILDIFIER_VERSION is required}"

arch="$(buildifier_arch)"
version="${BUILDIFIER_VERSION#v}"
url="https://github.com/bazelbuild/buildtools/releases/download/v${version}/buildifier-linux-${arch}"
tmp_file="$(mktemp)"

download "${url}" "${tmp_file}"
verify_sha256 "$(arch_sha256 BUILDIFIER)" "${tmp_file}"
install -m 0755 "${tmp_file}" /usr/local/bin/buildifier
rm -f "${tmp_file}"

buildifier --version
clean_caches
