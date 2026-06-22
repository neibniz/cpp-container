#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${BUF_VERSION:?BUF_VERSION is required}"

arch="$(buf_arch)"
version="${BUF_VERSION#v}"
url="https://github.com/bufbuild/buf/releases/download/v${version}/buf-Linux-${arch}"
tmp_file="$(mktemp)"

download "${url}" "${tmp_file}"
verify_sha256 "$(arch_sha256 BUF)" "${tmp_file}"
install -m 0755 "${tmp_file}" /usr/local/bin/buf
rm -f "${tmp_file}"

buf --version
clean_caches
