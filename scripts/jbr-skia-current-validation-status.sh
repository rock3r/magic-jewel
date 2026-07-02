#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)"
EVIDENCE_FILE="${EVIDENCE_FILE:-${ROOT_DIR}/scripts/jbr-skia-current-validation-evidence.env}"

latest_suite() {
  local suite_root="$1"
  find "${suite_root}" -mindepth 2 -maxdepth 2 -name suite.tsv -print 2>/dev/null | sort | tail -n 1
}

resolve_suite_path() {
  local path="$1"
  if [[ -z "${path}" || "${path}" == /* ]]; then
    printf "%s\n" "${path}"
  else
    printf "%s/%s\n" "${ROOT_DIR}" "${path}"
  fi
}

if [[ -f "${EVIDENCE_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${EVIDENCE_FILE}"
fi

STANDALONE_SUITE="${STANDALONE_SUITE:-${DEFAULT_STANDALONE_SUITE:-$(latest_suite "${ROOT_DIR}/out/jewel-standalone-focused-benchmark-suite")}}"
IDE_SUITE="${IDE_SUITE:-${DEFAULT_IDE_SUITE:-$(latest_suite "${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite")}}"
STANDALONE_SUITE="$(resolve_suite_path "${STANDALONE_SUITE}")"
IDE_SUITE="$(resolve_suite_path "${IDE_SUITE}")"
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
append_result "standalone powermetrics audit" "${standalone_perf_status}" "${standalone_perf_analysis}"
append_result "IDE powermetrics evidence gate" "${ide_perf_status}" "${ide_perf_analysis}"
append_result "IDE perf readiness probe" "${readiness_status}" "${readiness_log}"

readiness="$(awk -F= '$1 == "readiness" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"
reason="$(awk -F= '$1 == "reason" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"
load_1="$(awk -F= '$1 == "load_1" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"
top_cpu="$(awk -F= '$1 == "top_cpu" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"
sudo_cached="$(awk -F= '$1 == "powermetrics_sudo_cached" { print $2; exit }' "${readiness_log}" 2>/dev/null || true)"

coverage_ready="false"
if [[ "${standalone_status}" -eq 0 && "${ide_status}" -eq 0 ]]; then
  coverage_ready="true"
fi

perf_evidence_ready="false"
if [[ "${ide_perf_status}" -eq 0 ]]; then
  perf_evidence_ready="true"
fi

completion_ready="false"
if [[ "${coverage_ready}" == "true" && "${perf_evidence_ready}" == "true" ]]; then
  completion_ready="true"
fi

{
  echo "- coverage_ready: ${coverage_ready}"
  echo "- perf_evidence_ready: ${perf_evidence_ready}"
  echo "- completion_ready: ${completion_ready}"
  echo "- readiness: ${readiness:-unknown}"
  echo "- readiness reason: ${reason:-unknown}"
  echo "- load_1: ${load_1:-unknown}"
  echo "- top_cpu: ${top_cpu:-unknown}"
  echo "- powermetrics_sudo_cached: ${sudo_cached:-unknown}"
  echo
  echo "Completion requires standalone coverage plus IDE command/visual/powermetrics evidence. The standalone powermetrics audit and current readiness probe are informational: standalone covers the broad showcase surface, while the IDE suite carries the sampled CPU/GPU power evidence; readiness only says whether another clean perf run can start right now."
} >> "${status_file}"

cat "${status_file}"

if [[ "${standalone_status}" -ne 0 || "${ide_status}" -ne 0 ]]; then
  exit 1
fi

if [[ "${ide_perf_status}" -ne 0 ]]; then
  exit 3
fi
