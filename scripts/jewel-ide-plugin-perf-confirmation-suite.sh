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
REQUIRE_CLEAN_PREFLIGHT="${REQUIRE_CLEAN_PREFLIGHT:-true}"
MAX_PREFLIGHT_LOAD_1="${MAX_PREFLIGHT_LOAD_1:-6.0}"
MAX_PREFLIGHT_TOP_CPU="${MAX_PREFLIGHT_TOP_CPU:-75.0}"

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
preflight_ps_file="${OUT_ROOT}/machine-preflight-ps.txt"
preflight_load_1="$(
  uptime | awk '
    {
      load = $0
      sub(/^.*load averages?: /, "", load)
      split(load, parts, /[ ,]+/)
      print parts[1]
    }' 2>/dev/null || true
)"
preflight_top_cpu=""
if command -v ps >/dev/null 2>&1 && command -v sort >/dev/null 2>&1; then
  ps -Ao pid,pcpu,pmem,comm 2>/dev/null | sort -k2 -nr | head -15 > "${preflight_ps_file}" || true
  preflight_top_cpu="$(awk 'NR == 1 { print $2; exit }' "${preflight_ps_file}" 2>/dev/null || true)"
fi
preflight_ready="true"
preflight_reasons=()
if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" != "true" ]]; then
  preflight_ready="false"
  preflight_reasons+=("powermetrics-sudo-missing")
fi
if [[ -n "${preflight_load_1}" ]] && ! awk -v value="${preflight_load_1}" -v max="${MAX_PREFLIGHT_LOAD_1}" 'BEGIN { exit value <= max ? 0 : 1 }'; then
  preflight_ready="false"
  preflight_reasons+=("load1>${MAX_PREFLIGHT_LOAD_1}")
fi
if [[ -n "${preflight_top_cpu}" ]] && ! awk -v value="${preflight_top_cpu}" -v max="${MAX_PREFLIGHT_TOP_CPU}" 'BEGIN { exit value <= max ? 0 : 1 }'; then
  preflight_ready="false"
  preflight_reasons+=("top-cpu>${MAX_PREFLIGHT_TOP_CPU}")
fi
preflight_reason="none"
if ((${#preflight_reasons[@]})); then
  preflight_reason="${preflight_reasons[*]}"
fi

{
  echo "== IDE perf confirmation preflight =="
  uptime || true
  echo
  if [[ -s "${preflight_ps_file}" ]]; then
    cat "${preflight_ps_file}"
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
  echo "require_clean_preflight=${REQUIRE_CLEAN_PREFLIGHT}"
  echo "max_preflight_load_1=${MAX_PREFLIGHT_LOAD_1}"
  echo "max_preflight_top_cpu=${MAX_PREFLIGHT_TOP_CPU}"
  echo "preflight_load_1=${preflight_load_1:-unknown}"
  echo "preflight_top_cpu=${preflight_top_cpu:-unknown}"
  echo "preflight_ready=${preflight_ready}"
  echo "preflight_reason=${preflight_reason}"
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

if [[ "${REQUIRE_CLEAN_PREFLIGHT}" == "true" && "${preflight_ready}" != "true" ]]; then
  cat >&2 <<EOF
error: perf preflight is not clean enough for a confirmation run: ${preflight_reason}
Set REQUIRE_CLEAN_PREFLIGHT=false to force the run, or rerun when the machine is quieter.
Wrote preflight snapshot: ${preflight_file}
EOF
  exit 3
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
