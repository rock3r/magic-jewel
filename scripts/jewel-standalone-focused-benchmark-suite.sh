#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-standalone-focused-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-90}"
WARMUP_SECONDS="${WARMUP_SECONDS:-10}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-2}"
JBR_SKIA_RENDER_MODE="${JBR_SKIA_RENDER_MODE:-commands}"
JEWEL_STANDALONE_SPECTRE_STRESS="${JEWEL_STANDALONE_SPECTRE_STRESS:-true}"
JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS="${JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS:-120}"
COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS:-false}"
POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS:-1000}"
POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS:-cpu_power,gpu_power}"

mkdir -p "${OUT_ROOT}"

machine_snapshot() {
  {
    echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "uname=$(uname -a)"
    echo "uptime=$(uptime)"
    echo "duration_seconds=${DURATION_SECONDS}"
    echo "warmup_seconds=${WARMUP_SECONDS}"
    echo "sample_interval_seconds=${SAMPLE_INTERVAL_SECONDS}"
    echo "spectre_stress_interval_millis=${JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS}"
    echo "collect_powermetrics=${COLLECT_POWERMETRICS}"
    echo "powermetrics_samplers=${POWERMETRICS_SAMPLERS}"
    echo "powermetrics_interval_ms=${POWERMETRICS_INTERVAL_MS}"
    echo "top_processes:"
    ps -Ao pid,pcpu,pmem,comm | sort -k2 -nr | head -20 || true
  } > "${OUT_ROOT}/machine-snapshot.txt"
}

summary_value() {
  local file="$1"
  local key="$2"
  grep -E "^${key}=" "${file}" | head -n 1 | cut -d= -f2-
}

run_case() {
  local name="$1"
  local mode="$2"
  local initial_view="$3"
  local frame_marker="$4"
  local out_dir="${OUT_ROOT}/${name}"
  echo "== ${name} (${mode}) =="
  mkdir -p "${out_dir}"
  env \
    OUT_DIR="${out_dir}" \
    SKIKO_VERSION="${SKIKO_VERSION}" \
    DURATION_SECONDS="${DURATION_SECONDS}" \
    WARMUP_SECONDS="${WARMUP_SECONDS}" \
    SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS}" \
    JBR_SKIA_RENDER_MODE="${JBR_SKIA_RENDER_MODE}" \
    EXPECT_SCREENSHOT_ASSERTION=false \
    OLD_GRADLE_TASK=runJewelStandalone \
    NEW_GRADLE_TASK=runJewelStandaloneJbrSkiaInterop \
    APP_PROCESS_QUERY=org.jetbrains.jewel.samples.standalone.SwingMainKt \
    CAPTURE_WINDOW_QUERY=JewelStandaloneJbrSkiaWindow \
    APP_FRAME_MARKER="${frame_marker}" \
    EXPECT_MIN_APP_NEW_FRAMES=1 \
    COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS}" \
    POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS}" \
    POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS}" \
    JEWEL_STANDALONE_INITIAL_VIEW="${initial_view}" \
    JEWEL_STANDALONE_INITIAL_COMPONENT= \
    JEWEL_STANDALONE_SPECTRE_STRESS="${JEWEL_STANDALONE_SPECTRE_STRESS}" \
    JEWEL_STANDALONE_SPECTRE_STRESS_MODE="${mode}" \
    JEWEL_STANDALONE_SPECTRE_COMPONENTS= \
    JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS="${JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS}" \
    "${SCRIPT_DIR}/jbr-skia-interop-report.sh" > "${out_dir}/report-path.txt"
}

write_suite_summary() {
  local suite_tsv="${OUT_ROOT}/suite.tsv"
  printf "case\tstatus\told_avg_cpu\tnew_avg_cpu\told_max_cpu\tnew_max_cpu\told_avg_rss_kb\tnew_avg_rss_kb\told_fps\tnew_fps\tjbr_command_fps\tjbr_command_frames\tfallbacks\tunsupported_max\told_powermetrics\tnew_powermetrics\treport\n" > "${suite_tsv}"
  local case_dir
  for case_dir in "${OUT_ROOT}"/*; do
    [[ -d "${case_dir}" && -f "${case_dir}/summary.properties" ]] || continue
    local name
    name="$(basename "${case_dir}")"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
      "${name}" \
      "$(summary_value "${case_dir}/summary.properties" validation_status)" \
      "$(summary_value "${case_dir}/summary.properties" old_avg_cpu)" \
      "$(summary_value "${case_dir}/summary.properties" new_avg_cpu)" \
      "$(summary_value "${case_dir}/summary.properties" old_max_cpu)" \
      "$(summary_value "${case_dir}/summary.properties" new_max_cpu)" \
      "$(summary_value "${case_dir}/summary.properties" old_avg_rss_kb)" \
      "$(summary_value "${case_dir}/summary.properties" new_avg_rss_kb)" \
      "$(summary_value "${case_dir}/summary.properties" app_old_fps)" \
      "$(summary_value "${case_dir}/summary.properties" app_new_fps)" \
      "$(summary_value "${case_dir}/summary.properties" jbr_command_fps)" \
      "$(summary_value "${case_dir}/summary.properties" jbr_command_frames)" \
      "$(summary_value "${case_dir}/summary.properties" fallback_new_count)" \
      "$(summary_value "${case_dir}/summary.properties" cmp_unsupported_max)" \
      "$(summary_value "${case_dir}/summary.properties" powermetrics_old_status)" \
      "$(summary_value "${case_dir}/summary.properties" powermetrics_new_status)" \
      "$(cat "${case_dir}/report-path.txt" 2>/dev/null || true)" >> "${suite_tsv}"
  done
  echo "${suite_tsv}"
}

machine_snapshot
run_case hypnotoad-animation hypnotoad Hypnotoad JEWEL_STANDALONE_FRAME
run_case markdown-scroll markdownScroll Markdown JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL
write_suite_summary
