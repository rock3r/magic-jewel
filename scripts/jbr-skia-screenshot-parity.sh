#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/out/jbr-skia-screenshot-parity/$(date +%Y%m%d-%H%M%S)}"
REPORT_SCRIPT="${REPORT_SCRIPT:-${SCRIPT_DIR}/jbr-skia-interop-report.sh}"
COMPARE_SCRIPT="${COMPARE_SCRIPT:-${SCRIPT_DIR}/compare-jbr-skia-window-screenshots.sh}"

mkdir -p "${OUT_DIR}"

CAPTURE_OLD_SCREENSHOT=true \
JBR_SKIA_RENDER_MODE=commands \
MAGIC_JEWEL_FIXED_ANIMATION_PHASE="${MAGIC_JEWEL_FIXED_ANIMATION_PHASE:-0.375}" \
MAGIC_JEWEL_FIXED_FRAME_TICKS="${MAGIC_JEWEL_FIXED_FRAME_TICKS:-12}" \
MAGIC_JEWEL_PAUSE_SWING_ANIMATION="${MAGIC_JEWEL_PAUSE_SWING_ANIMATION:-true}" \
MAGIC_JEWEL_COMPOSE_BLEND_MODE="${MAGIC_JEWEL_COMPOSE_BLEND_MODE:-true}" \
MAGIC_JEWEL_COMPOSE_COLOR_FILTER="${MAGIC_JEWEL_COMPOSE_COLOR_FILTER:-true}" \
MAGIC_JEWEL_COMPOSE_PATH_EFFECT="${MAGIC_JEWEL_COMPOSE_PATH_EFFECT:-true}" \
MAGIC_JEWEL_COMPOSE_DRAW_PATH="${MAGIC_JEWEL_COMPOSE_DRAW_PATH:-true}" \
MAGIC_JEWEL_COMPOSE_DRAW_ARC="${MAGIC_JEWEL_COMPOSE_DRAW_ARC:-true}" \
MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT="${MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT:-true}" \
MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT="${MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT:-true}" \
MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT="${MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT:-true}" \
MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT="${MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT:-true}" \
MAGIC_JEWEL_UNSUPPORTED_TEXT="${MAGIC_JEWEL_UNSUPPORTED_TEXT:-true}" \
MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT="${MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT:-true}" \
EXPECT_MIN_IMAGE_REFS="${EXPECT_MIN_IMAGE_REFS:-1}" \
OUT_DIR="${OUT_DIR}/report" \
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}" \
DURATION_SECONDS="${DURATION_SECONDS:-6}" \
WARMUP_SECONDS="${WARMUP_SECONDS:-1}" \
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}" \
"${REPORT_SCRIPT}"

compare_status=0
"${COMPARE_SCRIPT}" \
  "${OUT_DIR}/report/old-window.png" \
  "${OUT_DIR}/report/new-window.png" \
  "${OUT_DIR}/report/parity-diff.png" \
  > "${OUT_DIR}/parity.log" 2>&1 || compare_status=$?

{
  echo
  echo "## Screenshot Parity Diff"
  echo
  echo "- diff image: parity-diff.png"
  echo "- parity log: ../parity.log"
  echo
  echo '```text'
  cat "${OUT_DIR}/parity.log"
  echo '```'
} >> "${OUT_DIR}/report/report.md"

awk '
  function sanitize(value) {
    gsub(/[^A-Za-z0-9_]/, "_", value)
    return value
  }
  /^JBR_SKIA_SCREENSHOT_PARITY / {
    for (i = 2; i <= NF; i++) {
      split($i, value, "=")
      if (value[1] != "diffImage") {
        printf "screenshot_parity_%s=%s\n", value[1], value[2]
      }
    }
  }
  /^JBR_SKIA_SCREENSHOT_PARITY_REGION / {
    region = "unknown"
    for (i = 2; i <= NF; i++) {
      split($i, value, "=")
      if (value[1] == "name") {
        region = sanitize(value[2])
      }
    }
    for (i = 2; i <= NF; i++) {
      split($i, value, "=")
      if (value[1] != "name") {
        printf "screenshot_parity_region_%s_%s=%s\n", region, value[1], value[2]
      }
    }
  }
' "${OUT_DIR}/parity.log" >> "${OUT_DIR}/report/summary.properties"

cat > "${OUT_DIR}/summary.tsv" <<EOF_SUMMARY
status	report	parity	diff
$([ "${compare_status}" -eq 0 ] && echo passed || echo failed)	${OUT_DIR}/report/report.md	${OUT_DIR}/parity.log	${OUT_DIR}/report/parity-diff.png
EOF_SUMMARY

if [ "${compare_status}" -eq 0 ]; then
  echo "JBR_SKIA_SCREENSHOT_PARITY_SUITE passed out_dir=${OUT_DIR}"
else
  echo "JBR_SKIA_SCREENSHOT_PARITY_SUITE failed status=${compare_status} out_dir=${OUT_DIR}" >&2
fi
echo "summary=${OUT_DIR}/summary.tsv"
exit "${compare_status}"
