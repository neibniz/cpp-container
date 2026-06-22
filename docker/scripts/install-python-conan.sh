#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${PYTHON_VERSION:?PYTHON_VERSION is required}"
: "${CONAN_VERSION:?CONAN_VERSION is required}"

mkdir -p "${UV_PYTHON_INSTALL_DIR}" "${UV_TOOL_DIR}" "${UV_TOOL_BIN_DIR}"
uv python install "${PYTHON_VERSION}"
python_bin="$(uv python find "${PYTHON_VERSION}")"
ln -sf "${python_bin}" /usr/local/bin/python3
ln -sf "${python_bin}" /usr/local/bin/python

uv tool install --python "${PYTHON_VERSION}" "conan==${CONAN_VERSION}"
python --version
conan --version
uv cache clean || true
clean_caches
