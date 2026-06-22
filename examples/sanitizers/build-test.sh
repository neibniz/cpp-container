#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="${BUILD_ROOT:-${SCRIPT_DIR}/build}"
CXX="${CXX:-c++}"
SANITIZERS="${SANITIZERS:-all}"

compiler_version="$("${CXX}" --version | sed -n '1p')"
compiler_id="unknown"
case "${compiler_version,,}" in
  *clang*) compiler_id="clang" ;;
  *gcc*|*g++*) compiler_id="gcc" ;;
esac

if [[ "${SANITIZERS}" == "all" ]]; then
  sanitizer_list=(address thread undefined)
  if [[ "${compiler_id}" == "clang" ]]; then
    sanitizer_list+=(memory)
  fi
else
  SANITIZERS="${SANITIZERS//,/ }"
  read -r -a sanitizer_list <<< "${SANITIZERS}"
fi

run_sanitizer() {
  local sanitizer="$1"
  local define_expect=""
  local define_trigger=""
  local expected_pattern=""
  local flags=()
  local link_flags=()

  case "${sanitizer}" in
    address)
      define_expect="-DSAMPLE_EXPECT_ADDRESS=1"
      define_trigger="-DSAMPLE_TRIGGER_ADDRESS=1"
      expected_pattern="AddressSanitizer"
      flags=(-fsanitize=address)
      ;;
    thread)
      define_expect="-DSAMPLE_EXPECT_THREAD=1"
      define_trigger="-DSAMPLE_TRIGGER_THREAD=1"
      expected_pattern="ThreadSanitizer"
      flags=(-fsanitize=thread -pthread)
      link_flags=(-pthread)
      ;;
    undefined)
      define_expect="-DSAMPLE_EXPECT_UNDEFINED=1"
      define_trigger="-DSAMPLE_TRIGGER_UNDEFINED=1"
      expected_pattern="runtime error|UndefinedBehaviorSanitizer"
      flags=(-fsanitize=undefined -fno-sanitize-recover=undefined)
      ;;
    memory)
      if [[ "${compiler_id}" != "clang" ]]; then
        echo "skip memory: MemorySanitizer requires Clang"
        return 0
      fi
      define_expect="-DSAMPLE_EXPECT_MEMORY=1"
      define_trigger="-DSAMPLE_TRIGGER_MEMORY=1"
      expected_pattern="MemorySanitizer|use-of-uninitialized-value"
      flags=(
        -fsanitize=memory
        -fsanitize-memory-track-origins=2
        -fPIE
        -fno-optimize-sibling-calls
      )
      link_flags=(-pie)
      ;;
    *)
      echo "unsupported sanitizer: ${sanitizer}" >&2
      return 2
      ;;
  esac

  local case_dir="${BUILD_ROOT}/${compiler_id}/${sanitizer}"
  local clean_bin="${case_dir}/clean"
  local detect_bin="${case_dir}/detect"
  local detect_log="${case_dir}/detect.log"
  mkdir -p "${case_dir}"

  echo "==> ${compiler_id}: ${sanitizer} clean run"
  "${CXX}" -std=c++17 -O1 -g -fno-omit-frame-pointer \
    "${flags[@]}" "${define_expect}" \
    "${SCRIPT_DIR}/sanitizer_probe.cpp" \
    -o "${clean_bin}" "${link_flags[@]}"
  "${clean_bin}"

  echo "==> ${compiler_id}: ${sanitizer} expected detection"
  "${CXX}" -std=c++17 -O1 -g -fno-omit-frame-pointer \
    "${flags[@]}" "${define_expect}" "${define_trigger}" \
    "${SCRIPT_DIR}/sanitizer_probe.cpp" \
    -o "${detect_bin}" "${link_flags[@]}"

  set +e
  "${detect_bin}" >"${detect_log}" 2>&1
  local status=$?
  set -e

  if [[ "${status}" -eq 0 ]]; then
    echo "${sanitizer} did not report the expected issue" >&2
    cat "${detect_log}" >&2
    return 1
  fi

  if ! grep -Eiq "${expected_pattern}" "${detect_log}"; then
    echo "${sanitizer} failed, but output did not match ${expected_pattern}" >&2
    cat "${detect_log}" >&2
    return 1
  fi
}

for sanitizer in "${sanitizer_list[@]}"; do
  run_sanitizer "${sanitizer}"
done
