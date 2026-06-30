#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)"

STANDALONE_SUITE="${STANDALONE_SUITE:-${ROOT_DIR}/out/jewel-standalone-focused-benchmark-suite/20260630-042508/suite.tsv}"
IDE_SUITE="${IDE_SUITE:-${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite/20260630-022412/suite.tsv}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/current-validation-status/$(date +%Y%m%d-%H%M%S)}"
REQUIRED_STANDALONE_CASES="${REQUIRED_STANDALONE_CASES:-showcase-controls-tour,showcase-critical-tour,showcase-layout-text-tour,showcase-misc-tour}"
REQUIRED_STANDALONE_COMPONENTS="${REQUIRED_STANDALONE_COMPONENTS:-Buttons,Radio Buttons,Checkboxes,Menus,Tabs,Tooltips,Combo Boxes,TextFields,Scrollbars,TextAreas,SplitLayout,Banners,Typography,Brushes,Chips and trees,Progressbar,Icons,Links,Borders,Segmented Controls,Sliders}"

mkdir -p "${OUT_ROOT}"

status_file="${OUT_ROOT}/status.md"
standalone_analysis="${OUT_ROOT}/standalone-analysis.md"
standalone_perf_analysis="${OUT_ROOT}/standalone-perf-analysis.md"
ide_analysis="${OUT_ROOT}/ide-analysis.md"
ide_perf_analysis="${OUT_ROOT}/ide-perf-analysis.md"
readiness_log="${OUT_ROOT}/ide-readiness.log"

{
  echo "# JBR Skia Current Validation Status"
  echo
  echo "- generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "- standalone suite: \`${STANDALONE_SUITE}\`"
  echo "- IDE suite: \`${IDE_SUITE}\`"
  echo
} > "${status_file}"

standalone_status=0
REQUIRE_COMMAND_CLEAN=true \
REQUIRE_TOUR_COMPLETE=true \
REQUIRE_CASES="${REQUIRED_STANDALONE_CASES}" \
REQUIRE_COMPONENTS="${REQUIRED_STANDALONE_COMPONENTS}" \
  "${SCRIPT_DIR}/analyze-jewel-standalone-focused-benchmark-suite.sh" \
  "${STANDALONE_SUITE}" "${standalone_analysis}" \
  >"${standalone_analysis}.stdout" 2>"${standalone_analysis}.stderr" || standalone_status=$?

ide_status=0
REQUIRE_COMMAND_CLEAN=true \
REQUIRE_VISUAL_PROBES=true \
  "${SCRIPT_DIR}/analyze-jewel-ide-plugin-benchmark-suite.sh" \
  "${IDE_SUITE}" "${ide_analysis}" \
  >"${ide_analysis}.stdout" 2>"${ide_analysis}.stderr" || ide_status=$?

standalone_perf_status=0
REQUIRE_COMMAND_CLEAN=true \
REQUIRE_TOUR_COMPLETE=true \
REQUIRE_CASES="${REQUIRED_STANDALONE_CASES}" \
REQUIRE_COMPONENTS="${REQUIRED_STANDALONE_COMPONENTS}" \
REQUIRE_POWERMETRICS=true \
  "${SCRIPT_DIR}/analyze-jewel-standalone-focused-benchmark-suite.sh" \
  "${STANDALONE_SUITE}" "${standalone_perf_analysis}" \
  >"${standalone_perf_analysis}.stdout" 2>"${standalone_perf_analysis}.stderr" || standalone_perf_status=$?

ide_perf_status=0
REQUIRE_COMMAND_CLEAN=true \
REQUIRE_VISUAL_PROBES=true \
REQUIRE_POWERMETRICS=true \
  "${SCRIPT_DIR}/analyze-jewel-ide-plugin-benchmark-suite.sh" \
  "${IDE_SUITE}" "${ide_perf_analysis}" \
  >"${ide_perf_analysis}.stdout" 2>"${ide_perf_analysis}.stderr" || ide_perf_status=$?

readiness_status=0
OUT_ROOT="${OUT_ROOT}/ide-readiness" \
  "${SCRIPT_DIR}/jewel-ide-plugin-perf-readiness.sh" > "${readiness_log}" 2>&1 || readiness_status=$?

append_result() {
  local label="$1"
  local status="$2"
  local artifact="$3"
  if [[ "${status}" -eq 0 ]]; then
    echo "- ${label}: passed (\`${artifact}\`)" >> "${status_file}"
  else
    echo "- ${label}: failed status=${status} (\`${artifact}\`)" >> "${status_file}"
  fi
}

append_result "standalone command/tour/component gate" "${standalone_status}" "${standalone_analysis}"
append_result "IDE command/visual gate" "${ide_status}" "${ide_analysis}"
append_result "standalone powermetrics evidence gate" "${standalone_perf_status}" "${standalone_perf_analysis}"
append_result "IDE powermetrics evidence gate" "${ide_perf_status}" "${ide_perf_analysis}"
append_result "IDE perf readiness" "${readiness_status}" "${readiness_log}"

readiness="$(awk -F= '$1 == "readiness" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"
reason="$(awk -F= '$1 == "reason" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"
load_1="$(awk -F= '$1 == "load_1" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"
top_cpu="$(awk -F= '$1 == "top_cpu" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"
sudo_cached="$(awk -F= '$1 == "powermetrics_sudo_cached" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"

{
  echo "- readiness: ${readiness:-unknown}"
  echo "- readiness reason: ${reason:-unknown}"
  echo "- load_1: ${load_1:-unknown}"
  echo "- top_cpu: ${top_cpu:-unknown}"
  echo "- powermetrics_sudo_cached: ${sudo_cached:-unknown}"
  echo
  echo "The retained standalone and IDE coverage gates are expected to pass. Powermetrics evidence and perf readiness are expected to fail until fresh sampled powermetrics exists and the machine is quiet with sudo cached."
} >> "${status_file}"

cat "${status_file}"

if [[ "${standalone_status}" -ne 0 || "${ide_status}" -ne 0 ]]; then
  exit 1
fi

if [[ "${standalone_perf_status}" -ne 0 || "${ide_perf_status}" -ne 0 || "${readiness_status}" -ne 0 ]]; then
  exit 3
fi
