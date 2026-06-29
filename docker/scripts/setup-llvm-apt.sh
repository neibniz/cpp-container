#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${LLVM_MAJOR:=22}"
: "${LLVM_APT_KEY_SHA256:=8b2a587ffd672c4687e7581dad4b2f6c1bb2ad6b480cd9771ba2ff48e0b8c75d}"

llvm_codename() {
  local codename=""
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    codename="${VERSION_CODENAME:-}"
  fi

  [[ -n "${codename}" ]] || die "cannot determine Debian codename for apt.llvm.org"
  printf '%s\n' "${codename}"
}

codename="$(llvm_codename)"
keyring="/etc/apt/keyrings/apt.llvm.org.asc"
source_file="/etc/apt/sources.list.d/llvm-toolchain-${codename}-${LLVM_MAJOR}.list"

mkdir -p /etc/apt/keyrings /etc/apt/sources.list.d
download "https://apt.llvm.org/llvm-snapshot.gpg.key" "${keyring}"
verify_sha256 "${LLVM_APT_KEY_SHA256}" "${keyring}"
chmod 0644 "${keyring}"

cat > "${source_file}" <<EOF
deb [arch=$(deb_arch) signed-by=${keyring}] https://apt.llvm.org/${codename}/ llvm-toolchain-${codename}-${LLVM_MAJOR} main
EOF

clean_caches
