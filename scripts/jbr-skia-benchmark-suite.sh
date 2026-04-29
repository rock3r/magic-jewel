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
SUITE_TSV="${OUT_ROOT}/suite.tsv"
printf "case\tstatus\tfallbacks\told_samples\tnew_samples\told_avg_cpu\tnew_avg_cpu\tapp_old_fps\tapp_new_fps\tjbr_picture_fps\tjbr_command_fps\tjbr_command_frames\treport\n" > "${SUITE_TSV}"

summary_value() {
  local file="$1"
  local key="$2"
  grep -E "^${key}=" "${file}" | head -n 1 | cut -d= -f2-
}

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
  local old_samples
  old_samples="$(summary_value "${out_dir}/summary.properties" old_samples)"
  local new_samples
  new_samples="$(summary_value "${out_dir}/summary.properties" new_samples)"
  local old_avg_cpu
  old_avg_cpu="$(summary_value "${out_dir}/summary.properties" old_avg_cpu)"
  local new_avg_cpu
  new_avg_cpu="$(summary_value "${out_dir}/summary.properties" new_avg_cpu)"
  if [[ "${old_samples}" == "0" ]]; then
    old_avg_cpu=na
  fi
  if [[ "${new_samples}" == "0" ]]; then
    new_avg_cpu=na
  fi
  local app_old_fps
  app_old_fps="$(summary_value "${out_dir}/summary.properties" app_old_fps)"
  local app_new_fps
  app_new_fps="$(summary_value "${out_dir}/summary.properties" app_new_fps)"
  local jbr_picture_fps
  jbr_picture_fps="$(summary_value "${out_dir}/summary.properties" jbr_picture_fps)"
  local jbr_command_fps
  jbr_command_fps="$(summary_value "${out_dir}/summary.properties" jbr_command_fps)"
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${name}" "${status}" "${fallback}" "${old_samples}" "${new_samples}" \
    "${old_avg_cpu}" "${new_avg_cpu}" \
    "${app_old_fps}" "${app_new_fps}" "${jbr_picture_fps}" "${jbr_command_fps}" \
    "${command_frames}" "${report}" >> "${SUITE_TSV}"
  echo "status=${status} fallback_new_count=${fallback} jbr_picture_frames=${picture_frames} jbr_command_frames=${command_frames} report=${report}"
  [[ "${status}" == "passed" ]]
}

run_case picture JBR_SKIA_RENDER_MODE=picture
run_case commands JBR_SKIA_RENDER_MODE=commands EXPECT_MIN_IMAGE_REFS=1
run_case commands-stable-images JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0
run_case commands-dynamic-images JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0
run_case commands-resize-dynamic-images JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_AUTO_RESIZE=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true

echo "JBR_SKIA_BENCHMARK_SUITE passed out_root=${OUT_ROOT}"
echo "suite=${SUITE_TSV}"
