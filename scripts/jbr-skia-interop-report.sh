#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/out/jbr-skia-interop-report/$(date +%Y%m%d-%H%M%S)}"
DURATION_SECONDS="${DURATION_SECONDS:-20}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
GRADLE="${GRADLE:-${ROOT_DIR}/gradlew}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
CAPTURE_WINDOW_QUERY="${CAPTURE_WINDOW_QUERY:-MagicJewelJbrSkiaWindow}"
CMP_SCRIPTS_DIR="${CMP_SCRIPTS_DIR:-/Users/rock3r/src/cmp-jbr-skia-poc/compose/desktop/desktop/samples/scripts}"
CAPTURE_SCRIPT="${CAPTURE_SCRIPT:-${CMP_SCRIPTS_DIR}/capture-macos-window.sh}"
ASSERT_SCRIPT="${ASSERT_SCRIPT:-${CMP_SCRIPTS_DIR}/assert-jbr-skia-window-screenshot.sh}"
FALLBACK_MARKER="SKIKO_JBR_INTEROP_FALLBACK"
SKIKO_PICTURE_MARKER="SKIKO_JBR_INTEROP_PICTURE_FRAME"
JBR_PICTURE_MARKER="JBR_SKIA_INTEROP_PICTURE_FRAME"
SCREENSHOT_COUNTS_MARKER="JBR_SKIA_SCREENSHOT_COUNTS"

mkdir -p "${OUT_DIR}"

usage() {
  cat <<EOF_USAGE
Usage: $0 [--dry-run]

Runs Magic Jewel in old SwingGraphics mode and JBR-Skia-interoperability mode,
captures coarse process CPU/RSS samples, parses fallback and picture markers,
and writes a Markdown report.

Environment:
  OUT_DIR                  Report directory. Defaults under out/jbr-skia-interop-report/.
  DURATION_SECONDS         Seconds to keep each sample run alive. Default: 20.
  SAMPLE_INTERVAL_SECONDS  Seconds between ps samples. Default: 1.
  SKIKO_VERSION            Local Skiko version override. Default: 0.0.0-SNAPSHOT.
  DESKTOP_PATCH            Patched java.desktop classes. Default: /tmp/jbr-skia-run/desktop.
  JBR_API_SHIM             Public JBR API shim jar. Default: /tmp/jbr-api-shim.jar.
  JBR_SKIA_LIB             Native JBR Skia interop dylib. Default: /tmp/jbr-skia-native/libjbrskiainterop.dylib.
  CMP_SCRIPTS_DIR          CMP sample scripts directory containing capture/assert helpers.
  CAPTURE_WINDOW_QUERY     Window title/owner to capture. Default: MagicJewelJbrSkiaWindow.
EOF_USAGE
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

descendants_of() {
  local parent="$1"
  local child
  pgrep -P "${parent}" 2>/dev/null | while read -r child; do
    echo "${child}"
    descendants_of "${child}"
  done
}

process_tree() {
  local root_pid="$1"
  {
    echo "${root_pid}"
    descendants_of "${root_pid}"
  } | sort -u
}

kill_process_tree() {
  local root_pid="$1"
  local pids
  pids="$(process_tree "${root_pid}" | tr '\n' ' ')"
  if [[ -n "${pids// /}" ]]; then
    kill ${pids} 2>/dev/null || true
  fi
}

sample_process_tree() {
  local mode="$1"
  local root_pid="$2"
  local csv="$3"
  local timestamp
  local pids

  timestamp="$(date +%s)"
  pids="$(process_tree "${root_pid}" | tr '\n' ',' | sed 's/,$//')"
  if [[ -n "${pids}" ]]; then
    ps -o pid= -o pcpu= -o rss= -p "${pids}" 2>/dev/null | while read -r pid cpu rss; do
      [[ -n "${pid:-}" ]] || continue
      printf '%s,%s,%s,%s,%s\n' "${timestamp}" "${mode}" "${pid}" "${cpu}" "${rss}" >> "${csv}"
    done
  fi
}

launch_mode() {
  local mode="$1"
  cd "${ROOT_DIR}"
  if [[ "${mode}" == "old" ]]; then
    "${GRADLE}" --no-daemon run
  else
    SKIKO_VERSION="${SKIKO_VERSION}" "${SCRIPT_DIR}/run-jbr-skia.sh"
  fi
}

run_mode() {
  local mode="$1"
  local log="${OUT_DIR}/${mode}.log"
  local csv="${OUT_DIR}/${mode}-ps.csv"
  local screenshot="${OUT_DIR}/${mode}-window.png"
  local screenshot_assertion="${OUT_DIR}/${mode}-screenshot-assertion.log"
  local screenshot_status="${OUT_DIR}/${mode}-screenshot-status.txt"

  printf 'timestamp,mode,pid,cpu_percent,rss_kb\n' > "${csv}"

  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    echo "Would run Magic Jewel mode ${mode}" > "${log}"
    return
  fi

  launch_mode "${mode}" > "${log}" 2>&1 &

  local root_pid="$!"
  local end_time=$(( $(date +%s) + DURATION_SECONDS ))
  local screenshot_done=false

  set +e
  while kill -0 "${root_pid}" 2>/dev/null && [[ "$(date +%s)" -lt "${end_time}" ]]; do
    sample_process_tree "${mode}" "${root_pid}" "${csv}"
    if [[ "${mode}" == "new"
        && "${screenshot_done}" == "false"
        && -x "${CAPTURE_SCRIPT}"
        && -x "${ASSERT_SCRIPT}"
        && $(grep -c "${SKIKO_PICTURE_MARKER}" "${log}" 2>/dev/null) -gt 0 ]]; then
      if "${CAPTURE_SCRIPT}" "${CAPTURE_WINDOW_QUERY}" "${screenshot}" > "${OUT_DIR}/${mode}-capture.log" 2>&1; then
        if "${ASSERT_SCRIPT}" "${screenshot}" > "${screenshot_assertion}" 2>&1; then
          echo "passed" > "${screenshot_status}"
          screenshot_done=true
        fi
      fi
    fi
    sleep "${SAMPLE_INTERVAL_SECONDS}"
  done

  kill_process_tree "${root_pid}"
  wait "${root_pid}" >/dev/null 2>&1
  set -e
}

summarize_csv() {
  local csv="$1"
  awk -F, '
    NR > 1 {
      cpu += $4
      rss += $5
      if ($4 > maxCpu) maxCpu = $4
      if ($5 > maxRss) maxRss = $5
      count++
    }
    END {
      if (count == 0) {
        printf "samples=0 avg_cpu=0 max_cpu=0 avg_rss_kb=0 max_rss_kb=0"
      } else {
        printf "samples=%d avg_cpu=%.2f max_cpu=%.2f avg_rss_kb=%.0f max_rss_kb=%.0f", count, cpu / count, maxCpu, rss / count, maxRss
      }
    }
  ' "${csv}"
}

picture_marker_summary() {
  local marker="$1"
  local log="$2"
  awk -v marker="${marker}" '
    index($0, marker) {
      frames++
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^bytes=/) {
          split($i, value, "=")
          bytes += value[2]
          if (value[2] > maxBytes) maxBytes = value[2]
        }
      }
    }
    END {
      if (frames == 0) {
        printf "frames=0 avg_bytes=0 max_bytes=0"
      } else {
        printf "frames=%d avg_bytes=%.0f max_bytes=%.0f", frames, bytes / frames, maxBytes
      }
    }
  ' "${log}"
}

write_report() {
  local report="${OUT_DIR}/report.md"
  local old_summary
  local new_summary
  local old_markers
  local new_markers
  local skiko_picture_summary
  local jbr_picture_summary
  local screenshot_counts
  local screenshot_status

  old_summary="$(summarize_csv "${OUT_DIR}/old-ps.csv")"
  new_summary="$(summarize_csv "${OUT_DIR}/new-ps.csv")"
  old_markers="$(grep -c "${FALLBACK_MARKER}" "${OUT_DIR}/old.log" 2>/dev/null || true)"
  new_markers="$(grep -c "${FALLBACK_MARKER}" "${OUT_DIR}/new.log" 2>/dev/null || true)"
  skiko_picture_summary="$(picture_marker_summary "${SKIKO_PICTURE_MARKER}" "${OUT_DIR}/new.log")"
  jbr_picture_summary="$(picture_marker_summary "${JBR_PICTURE_MARKER}" "${OUT_DIR}/new.log")"
  screenshot_counts="$(grep "${SCREENSHOT_COUNTS_MARKER}" "${OUT_DIR}/new-screenshot-assertion.log" 2>/dev/null || true)"
  screenshot_status="$(cat "${OUT_DIR}/new-screenshot-status.txt" 2>/dev/null || true)"

  {
    echo "# Magic Jewel JBR Skia Interop Report"
    echo
    echo "- Generated: $(date -Iseconds)"
    echo "- Duration per mode: ${DURATION_SECONDS}s"
    echo "- Root: ${ROOT_DIR}"
    echo "- SKIKO_VERSION: ${SKIKO_VERSION}"
    echo
    echo "## Modes"
    echo
    echo "- old: ./gradlew --no-daemon run"
    echo "- new: ./scripts/run-jbr-skia.sh"
    echo
    echo "## Process Samples"
    echo
    echo "- old: ${old_summary}"
    echo "- new: ${new_summary}"
    echo
    echo "## Fallback Markers"
    echo
    echo "- old marker count: ${old_markers}"
    echo "- new marker count: ${new_markers}"
    echo
    echo "## Picture Replay Markers"
    echo
    echo "- Skiko picture frames: ${skiko_picture_summary}"
    echo "- JBR picture replays: ${jbr_picture_summary}"
    echo
    echo "## Screenshot Assertion"
    echo
    if [[ -n "${screenshot_counts}" ]]; then
      echo "- status: ${screenshot_status:-unknown}"
      echo "- ${screenshot_counts}"
      echo "- screenshot: new-window.png"
      echo "- assertion log: new-screenshot-assertion.log"
    else
      echo "- not run"
    fi
    echo
    echo "## Files"
    echo
    echo "- old log: old.log"
    echo "- new log: new.log"
    echo "- old ps samples: old-ps.csv"
    echo "- new ps samples: new-ps.csv"
    echo
    echo "## Notes"
    echo
    echo "CPU and RSS samples are coarse process-tree samples from ps. They are useful as a smoke signal only."
    echo "Picture marker counts come from structured Skiko/JBR logs and are the primary signal that the JBR-owned replay path was used."
    echo "The new mode depends on patched local JBR, Skiko, and CMP artifacts; see README.md for the required paths and overrides."
  } > "${report}"

  echo "${report}"
}

run_mode old
run_mode new
write_report
