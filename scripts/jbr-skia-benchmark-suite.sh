#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-20}"
WARMUP_SECONDS="${WARMUP_SECONDS:-5}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
ENABLE_ASPROF="${ENABLE_ASPROF:-false}"

mkdir -p "${OUT_ROOT}"

run_case() {
  local name="$1"
  shift
  local out_dir="${OUT_ROOT}/${name}"
  echo "== ${name} =="
  env \
    OUT_DIR="${out_dir}" \
    DURATION_SECONDS="${DURATION_SECONDS}" \
    WARMUP_SECONDS="${WARMUP_SECONDS}" \
    SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS}" \
    SKIKO_VERSION="${SKIKO_VERSION}" \
    ENABLE_ASPROF="${ENABLE_ASPROF}" \
    "$@" \
    "${SCRIPT_DIR}/jbr-skia-interop-report.sh" >/tmp/magic-jewel-${name}-benchmark-report.txt
  local report
  report="$(cat /tmp/magic-jewel-${name}-benchmark-report.txt)"
  local status
  status="$(grep -E '^validation_status=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local command_frames
  command_frames="$(grep -E '^jbr_command_frames=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local picture_frames
  picture_frames="$(grep -E '^jbr_picture_frames=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local fallback
  fallback="$(grep -E '^fallback_new_count=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  echo "status=${status} fallback_new_count=${fallback} jbr_picture_frames=${picture_frames} jbr_command_frames=${command_frames} report=${report}"
  [[ "${status}" == "passed" ]]
}

run_case picture JBR_SKIA_RENDER_MODE=picture
run_case commands JBR_SKIA_RENDER_MODE=commands EXPECT_MIN_IMAGE_REFS=1
run_case commands-stable-images JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0
run_case commands-dynamic-images JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0
run_case commands-resize-dynamic-images JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_AUTO_RESIZE=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true

echo "JBR_SKIA_BENCHMARK_SUITE passed out_root=${OUT_ROOT}"
