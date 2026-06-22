#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
BUILD_TYPE="${BUILD_TYPE:-Debug}"
SANITIZER="${SANITIZER:-address-undefined}"
CXX="${CXX:-c++}"

compiler_version="$("${CXX}" --version | sed -n '1p')"
compiler_id="unknown"
case "${compiler_version,,}" in
  *clang*) compiler_id="clang" ;;
  *gcc*|*g++*) compiler_id="gcc" ;;
esac

BUILD_DIR="${BUILD_DIR:-${SCRIPT_DIR}/build/${compiler_id}-${SANITIZER}-${BUILD_TYPE}}"

buf lint "${ROOT_DIR}"
conan profile detect --force
conan install "${SCRIPT_DIR}" \
  --output-folder "${BUILD_DIR}" \
  --build=missing \
  -s "build_type=${BUILD_TYPE}"

cmake -S "${SCRIPT_DIR}" -B "${BUILD_DIR}" -G Ninja \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DCMAKE_TOOLCHAIN_FILE="${BUILD_DIR}/conan_toolchain.cmake" \
  -DSAMPLE_SANITIZER="${SANITIZER}"

cmake --build "${BUILD_DIR}"
ctest --test-dir "${BUILD_DIR}" --output-on-failure
