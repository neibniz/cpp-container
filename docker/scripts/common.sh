#!/usr/bin/env bash
set -Eeuo pipefail

log() {
  printf '[cpp-container] %s\n' "$*"
}

die() {
  printf '[cpp-container] error: %s\n' "$*" >&2
  exit 1
}

deb_arch() {
  if [[ -n "${TARGETARCH:-}" ]]; then
    printf '%s\n' "${TARGETARCH}"
    return
  fi
  dpkg --print-architecture
}

cmake_arch() {
  case "$(deb_arch)" in
    amd64) printf 'x86_64\n' ;;
    arm64) printf 'aarch64\n' ;;
    *) die "unsupported architecture for CMake: $(deb_arch)" ;;
  esac
}

uv_target() {
  case "$(deb_arch)" in
    amd64) printf 'x86_64-unknown-linux-gnu\n' ;;
    arm64) printf 'aarch64-unknown-linux-gnu\n' ;;
    *) die "unsupported architecture for uv: $(deb_arch)" ;;
  esac
}

bazelisk_arch() {
  case "$(deb_arch)" in
    amd64) printf 'amd64\n' ;;
    arm64) printf 'arm64\n' ;;
    *) die "unsupported architecture for Bazelisk: $(deb_arch)" ;;
  esac
}

buildifier_arch() {
  case "$(deb_arch)" in
    amd64) printf 'amd64\n' ;;
    arm64) printf 'arm64\n' ;;
    *) die "unsupported architecture for Buildifier: $(deb_arch)" ;;
  esac
}

buf_arch() {
  case "$(deb_arch)" in
    amd64) printf 'x86_64\n' ;;
    arm64) printf 'aarch64\n' ;;
    *) die "unsupported architecture for buf: $(deb_arch)" ;;
  esac
}

apt_install() {
  log "Installing apt packages: $*"
  apt-get update
  apt-get install -y --no-install-recommends "$@"
  rm -rf /var/lib/apt/lists/*
}

download() {
  local url="$1"
  local output="$2"
  log "Downloading ${url}"
  curl -fsSL --retry 5 --retry-delay 2 -o "${output}" "${url}"
}

arch_sha256() {
  local prefix="$1"
  local variable
  case "$(deb_arch)" in
    amd64) variable="${prefix}_AMD64_SHA256" ;;
    arm64) variable="${prefix}_ARM64_SHA256" ;;
    *) die "unsupported architecture for ${prefix} checksum: $(deb_arch)" ;;
  esac

  local value="${!variable:-}"
  [[ -n "${value}" ]] || die "missing checksum variable: ${variable}"
  printf '%s\n' "${value#sha256:}"
}

verify_sha256() {
  local expected="$1"
  local file="$2"
  log "Verifying sha256 for ${file}"
  printf '%s  %s\n' "${expected}" "${file}" | sha256sum -c -
}

clean_caches() {
  rm -rf /var/tmp/* /root/.cache
  rm -rf /var/lib/apt/lists/*
}
