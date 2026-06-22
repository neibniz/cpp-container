#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${CMAKE_VERSION:?CMAKE_VERSION is required}"

arch="$(cmake_arch)"
version="${CMAKE_VERSION#v}"
url="https://github.com/Kitware/CMake/releases/download/v${version}/cmake-${version}-linux-${arch}.tar.gz"
tmp_dir="$(mktemp -d)"

download "${url}" "${tmp_dir}/cmake.tar.gz"
verify_sha256 "$(arch_sha256 CMAKE)" "${tmp_dir}/cmake.tar.gz"
mkdir -p /opt/cmake
tar -xzf "${tmp_dir}/cmake.tar.gz" --strip-components=1 -C /opt/cmake
ln -sf /opt/cmake/bin/cmake /usr/local/bin/cmake
ln -sf /opt/cmake/bin/ctest /usr/local/bin/ctest
ln -sf /opt/cmake/bin/cpack /usr/local/bin/cpack
rm -rf /opt/cmake/doc /opt/cmake/man /opt/cmake/share/doc /opt/cmake/share/man "${tmp_dir}"

cmake --version
clean_caches
