#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)"

OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
CASES="${CASES:-redraw hypnotoad chat}"
VARIANTS="${VARIANTS:-old new}"
SAMPLE_SECONDS="${SAMPLE_SECONDS:-60}"
COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS:-true}"
COLLECT_THREAD_CPU="${COLLECT_THREAD_CPU:-true}"
PAINT_PROBE="${PAINT_PROBE:-true}"
POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS:-500}"
POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS:-cpu_power,gpu_power}"
PREFLIGHT_ONLY="${PREFLIGHT_ONLY:-false}"

powermetrics_sudo_cached="not-required"
if [[ "${COLLECT_POWERMETRICS}" == "true" ]]; then
  if sudo -n true 2>/dev/null; then
    powermetrics_sudo_cached="true"
  else
    powermetrics_sudo_cached="false"
  fi
fi

mkdir -p "${OUT_ROOT}"
preflight_file="${OUT_ROOT}/machine-preflight.txt"

{
  echo "== IDE perf confirmation preflight =="
  uptime || true
  echo
  if command -v ps >/dev/null 2>&1 && command -v sort >/dev/null 2>&1; then
    ps -Ao pid,pcpu,pmem,comm 2>/dev/null | sort -k2 -nr | head -15 || true
  fi
  echo
  echo "out_root=${OUT_ROOT}"
  echo "cases=${CASES}"
  echo "variants=${VARIANTS}"
  echo "sample_seconds=${SAMPLE_SECONDS}"
  echo "collect_powermetrics=${COLLECT_POWERMETRICS}"
  echo "collect_thread_cpu=${COLLECT_THREAD_CPU}"
  echo "paint_probe=${PAINT_PROBE}"
  echo "powermetrics_interval_ms=${POWERMETRICS_INTERVAL_MS}"
  echo "powermetrics_samplers=${POWERMETRICS_SAMPLERS}"
  echo "powermetrics_sudo_cached=${powermetrics_sudo_cached}"
  echo "preflight_only=${PREFLIGHT_ONLY}"
} | tee "${preflight_file}"

if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" != "true" ]]; then
  cat >&2 <<EOF
error: COLLECT_POWERMETRICS=true requires a cached sudo credential for powermetrics.
Run \`sudo -v\` first, or rerun with COLLECT_POWERMETRICS=false for CPU/thread/command timing only.
Wrote preflight snapshot: ${preflight_file}
EOF
  exit 2
fi

if [[ "${PREFLIGHT_ONLY}" == "true" ]]; then
  echo "PREFLIGHT_ONLY=true; wrote ${preflight_file}"
  exit 0
fi

exec env \
  OUT_ROOT="${OUT_ROOT}" \
  CASES="${CASES}" \
  VARIANTS="${VARIANTS}" \
  SAMPLE_SECONDS="${SAMPLE_SECONDS}" \
  COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS}" \
  COLLECT_THREAD_CPU="${COLLECT_THREAD_CPU}" \
  PAINT_PROBE="${PAINT_PROBE}" \
  POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS}" \
  POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS}" \
  "${SCRIPT_DIR}/jewel-ide-plugin-benchmark-suite.sh"
