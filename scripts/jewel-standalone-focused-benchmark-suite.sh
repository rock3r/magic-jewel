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
JBR_SKIA_INTEROP_JVM_ARGS="${JBR_SKIA_INTEROP_JVM_ARGS:--Dcompose.jbr.skia.command.logOpCounts=true}"
EXPECT_SCREENSHOT_ASSERTION="${EXPECT_SCREENSHOT_ASSERTION:-false}"
CASES="${CASES:-hypnotoad-animation markdown-editor-preview-readme80-auto markdown-preview-readme80-auto markdown-preview-readme80-wheel}"

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
  local markdown_content="${5:-readme80}"
  local markdown_preview_only="${6:-false}"
  local markdown_auto_scroll="${7:-false}"
  local spectre_stress="${8:-${JEWEL_STANDALONE_SPECTRE_STRESS}}"
  local initial_component="${9:-}"
  local expect_min_app_new_frames="${10:-1}"
  local markdown_stable_images="${11:-true}"
  local out_dir="${OUT_ROOT}/${name}"
  echo "== ${name} (${mode}) =="
  mkdir -p "${out_dir}"
  env \
    JBR_SKIA_INTEROP_EXTRA_JVM_ARGS="${JBR_SKIA_INTEROP_JVM_ARGS}" \
    OUT_DIR="${out_dir}" \
    SKIKO_VERSION="${SKIKO_VERSION}" \
    DURATION_SECONDS="${DURATION_SECONDS}" \
    WARMUP_SECONDS="${WARMUP_SECONDS}" \
    SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS}" \
    JBR_SKIA_RENDER_MODE="${JBR_SKIA_RENDER_MODE}" \
    EXPECT_SCREENSHOT_ASSERTION="${EXPECT_SCREENSHOT_ASSERTION}" \
    OLD_GRADLE_TASK=runJewelStandalone \
    NEW_GRADLE_TASK=runJewelStandaloneJbrSkiaInterop \
    APP_PROCESS_QUERY=org.jetbrains.jewel.samples.standalone.SwingMainKt \
    CAPTURE_WINDOW_QUERY=JewelStandaloneJbrSkiaWindow \
    APP_FRAME_MARKER="${frame_marker}" \
    EXPECT_MIN_APP_NEW_FRAMES="${expect_min_app_new_frames}" \
    COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS}" \
    POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS}" \
    POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS}" \
    JEWEL_STANDALONE_INITIAL_VIEW="${initial_view}" \
    JEWEL_STANDALONE_INITIAL_COMPONENT="${initial_component}" \
    JEWEL_STANDALONE_MARKDOWN_CONTENT="${markdown_content}" \
    JEWEL_STANDALONE_MARKDOWN_PREVIEW_ONLY="${markdown_preview_only}" \
    JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL="${markdown_auto_scroll}" \
    JEWEL_STANDALONE_MARKDOWN_STABLE_IMAGES="${markdown_stable_images}" \
    JEWEL_STANDALONE_SPECTRE_STRESS="${spectre_stress}" \
    JEWEL_STANDALONE_SPECTRE_STRESS_MODE="${mode}" \
    JEWEL_STANDALONE_SPECTRE_COMPONENTS= \
    JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS="${JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS}" \
    "${SCRIPT_DIR}/jbr-skia-interop-report.sh" > "${out_dir}/report-path.txt"
}

should_run_case() {
  local name="$1"
  [[ " ${CASES} " == *" ${name} "* ]]
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
should_run_case hypnotoad-animation &&
  run_case hypnotoad-animation hypnotoad Hypnotoad JEWEL_STANDALONE_FRAME readme80 false false true
should_run_case markdown-editor-preview-readme80-auto &&
  run_case markdown-editor-preview-readme80-auto markdownAutoScroll Markdown JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL readme80 false true false
should_run_case markdown-preview-readme80-auto &&
  run_case markdown-preview-readme80-auto markdownAutoScroll Markdown JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL readme80 true true false
should_run_case markdown-preview-readme80-wheel &&
  run_case markdown-preview-readme80-wheel markdownWheel Markdown JEWEL_STANDALONE_SPECTRE readme80 true false true
should_run_case markdown-preview-readme80-static &&
  run_case markdown-preview-readme80-static idle Markdown JEWEL_STANDALONE_FRAME readme80 true false false "" 0
should_run_case showcase-icons &&
  run_case showcase-icons idle Components JEWEL_STANDALONE_FRAME readme80 false false false Icons 0
should_run_case markdown-preview-readme20-auto &&
  run_case markdown-preview-readme20-auto markdownAutoScroll Markdown JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL readme20 true true false
should_run_case markdown-preview-readme40-auto &&
  run_case markdown-preview-readme40-auto markdownAutoScroll Markdown JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL readme40 true true false
should_run_case markdown-preview-readme160-auto &&
  run_case markdown-preview-readme160-auto markdownAutoScroll Markdown JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL readme160 true true false
should_run_case markdown-preview-catalog-head-auto &&
  run_case markdown-preview-catalog-head-auto markdownAutoScroll Markdown JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL catalogHead true true false
should_run_case markdown-preview-catalog-auto &&
  run_case markdown-preview-catalog-auto markdownAutoScroll Markdown JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL catalog true true false
should_run_case markdown-preview-raw-readme80-static &&
  run_case markdown-preview-raw-readme80-static idle Markdown JEWEL_STANDALONE_FRAME rawReadme80 true false false "" 0 false
write_suite_summary
