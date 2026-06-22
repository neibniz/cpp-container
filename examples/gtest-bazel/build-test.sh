#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
SANITIZERS="${SANITIZERS:-${SANITIZER:-address-undefined}}"

buf lint "${ROOT_DIR}"
cd "${ROOT_DIR}"

SANITIZERS="${SANITIZERS//,/ }"
for sanitizer in ${SANITIZERS}; do
  bazel test \
    --test_output=all \
    --action_env=CC \
    --action_env=CXX \
    --repo_env=CC \
    --repo_env=CXX \
    --define "sanitizer=${sanitizer}" \
    //examples/gtest-bazel:sample_test
done
