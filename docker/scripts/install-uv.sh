#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${UV_VERSION:?UV_VERSION is required}"

target="$(uv_target)"
version="${UV_VERSION#v}"
url="https://github.com/astral-sh/uv/releases/download/${version}/uv-${target}.tar.gz"
tmp_dir="$(mktemp -d)"

download "${url}" "${tmp_dir}/uv.tar.gz"
verify_sha256 "$(arch_sha256 UV)" "${tmp_dir}/uv.tar.gz"
tar -xzf "${tmp_dir}/uv.tar.gz" -C "${tmp_dir}"
install -m 0755 "$(find "${tmp_dir}" -type f -name uv | head -n 1)" /usr/local/bin/uv
install -m 0755 "$(find "${tmp_dir}" -type f -name uvx | head -n 1)" /usr/local/bin/uvx
rm -rf "${tmp_dir}"

uv --version
clean_caches
