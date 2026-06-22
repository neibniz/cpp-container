#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${BAZELISK_VERSION:?BAZELISK_VERSION is required}"

arch="$(bazelisk_arch)"
version="${BAZELISK_VERSION#v}"
url="https://github.com/bazelbuild/bazelisk/releases/download/v${version}/bazelisk-linux-${arch}"
tmp_file="$(mktemp)"

download "${url}" "${tmp_file}"
verify_sha256 "$(arch_sha256 BAZELISK)" "${tmp_file}"
install -m 0755 "${tmp_file}" /usr/local/bin/bazelisk
ln -sf /usr/local/bin/bazelisk /usr/local/bin/bazel
rm -f "${tmp_file}"

mkdir -p "${BAZELISK_HOME}"
chmod 0777 "${BAZELISK_HOME}"

if [[ "${PREFETCH_BAZEL:-1}" == "1" ]]; then
  bazel --version
fi

clean_caches
