#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/out/jbr-skia-interop-report/$(date +%Y%m%d-%H%M%S)}"
DURATION_SECONDS="${DURATION_SECONDS:-20}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
STARTUP_TIMEOUT_SECONDS="${STARTUP_TIMEOUT_SECONDS:-45}"
GRADLE="${GRADLE:-${ROOT_DIR}/gradlew}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
CAPTURE_WINDOW_QUERY="${CAPTURE_WINDOW_QUERY:-MagicJewelJbrSkiaWindow}"
APP_PROCESS_QUERY="${APP_PROCESS_QUERY:-com.magicjewel.MainKt}"
CMP_SCRIPTS_DIR="${CMP_SCRIPTS_DIR:-/Users/rock3r/src/cmp-jbr-skia-poc/compose/desktop/desktop/samples/scripts}"
CAPTURE_SCRIPT="${CAPTURE_SCRIPT:-${CMP_SCRIPTS_DIR}/capture-macos-window.sh}"
ASSERT_SCRIPT="${ASSERT_SCRIPT:-${SCRIPT_DIR}/assert-jbr-skia-mixed-window-screenshot.sh}"
COMMAND_ASSERT_SCRIPT="${COMMAND_ASSERT_SCRIPT:-${SCRIPT_DIR}/assert-jbr-skia-command-window-screenshot.sh}"
FALLBACK_MARKER="SKIKO_JBR_INTEROP_FALLBACK"
APP_FRAME_MARKER="MAGIC_JEWEL_COMPOSE_FRAME"
SWING_FRAME_MARKER="MAGIC_JEWEL_SWING_FRAME"
SKIKO_PICTURE_MARKER="SKIKO_JBR_INTEROP_PICTURE_FRAME"
JBR_PICTURE_MARKER="JBR_SKIA_INTEROP_PICTURE_FRAME"
SKIKO_COMMAND_MARKER="SKIKO_JBR_INTEROP_COMMAND_FRAME"
JBR_COMMAND_MARKER="JBR_SKIA_INTEROP_COMMAND_FRAME"
CMP_COMMAND_RECORDER_MARKER="CMP_JBR_COMMAND_RECORDER_FRAME"
SCREENSHOT_COUNTS_MARKER="JBR_SKIA_SCREENSHOT_COUNTS"
MIXED_SCREENSHOT_COUNTS_MARKER="JBR_SKIA_MIXED_SCREENSHOT_COUNTS"
COMMAND_SCREENSHOT_COUNTS_MARKER="JBR_SKIA_COMMAND_SCREENSHOT_COUNTS"

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
  STARTUP_TIMEOUT_SECONDS  Seconds to wait for the app process before measuring. Default: 45.
  SKIKO_VERSION            Local Skiko version override. Default: 0.0.0-SNAPSHOT.
  JBR_SKIA_RENDER_MODE     New-mode renderer: picture, commands, or diagnostic. Default: picture.
  DESKTOP_PATCH            Patched java.desktop classes. Default: /tmp/jbr-skia-run/desktop.
  JBR_API_SHIM             Public JBR API shim jar. Default: /tmp/jbr-api-shim.jar.
  JBR_SKIA_LIB             Native JBR Skia interop dylib. Default: /tmp/jbr-skia-native/libjbrskiainterop.dylib.
  CMP_SCRIPTS_DIR          CMP sample scripts directory containing the capture helper.
  ASSERT_SCRIPT            Picture/mixed-mode screenshot assertion helper.
  COMMAND_ASSERT_SCRIPT    Command-mode screenshot assertion helper.
  CAPTURE_WINDOW_QUERY     Window title/owner to capture. Default: MagicJewelJbrSkiaWindow.
  APP_PROCESS_QUERY        Process command substring for the launched app. Default: com.magicjewel.MainKt.
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
    pgrep -f "${APP_PROCESS_QUERY}" 2>/dev/null || true
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
  local ready_marker="${SKIKO_PICTURE_MARKER}"
  local assert_script="${ASSERT_SCRIPT}"

  if [[ "${JBR_SKIA_RENDER_MODE:-picture}" == "commands" ]]; then
    ready_marker="${SKIKO_COMMAND_MARKER}"
    assert_script="${COMMAND_ASSERT_SCRIPT}"
  fi

  printf 'timestamp,mode,pid,cpu_percent,rss_kb\n' > "${csv}"

  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    echo "Would run Magic Jewel mode ${mode}" > "${log}"
    return
  fi

  launch_mode "${mode}" > "${log}" 2>&1 &

  local root_pid="$!"
  local startup_deadline=$(( $(date +%s) + STARTUP_TIMEOUT_SECONDS ))
  local end_time=0
  local screenshot_done=false

  set +e
  while kill -0 "${root_pid}" 2>/dev/null; do
    local now
    now="$(date +%s)"
    if [[ "${end_time}" -eq 0 ]]; then
      if pgrep -f "${APP_PROCESS_QUERY}" >/dev/null 2>&1 || [[ "${now}" -ge "${startup_deadline}" ]]; then
        end_time=$(( now + DURATION_SECONDS ))
      else
        sleep "${SAMPLE_INTERVAL_SECONDS}"
        continue
      fi
    fi
    [[ "${now}" -lt "${end_time}" ]] || break
    sample_process_tree "${mode}" "${root_pid}" "${csv}"
    if [[ "${mode}" == "new"
        && "${screenshot_done}" == "false"
        && -x "${CAPTURE_SCRIPT}"
        && -x "${assert_script}"
        && $(grep -c "${ready_marker}" "${log}" 2>/dev/null) -gt 0 ]]; then
      if "${CAPTURE_SCRIPT}" "${CAPTURE_WINDOW_QUERY}" "${screenshot}" > "${OUT_DIR}/${mode}-capture.log" 2>&1; then
        if "${assert_script}" "${screenshot}" > "${screenshot_assertion}" 2>&1; then
          echo "passed" > "${screenshot_status}"
          screenshot_done=true
        fi
      fi
    fi
    sleep "${SAMPLE_INTERVAL_SECONDS}"
  done

  if [[ "${mode}" == "new"
      && "${screenshot_done}" == "false"
      && -x "${CAPTURE_SCRIPT}"
      && -x "${assert_script}"
      && $(grep -c "${ready_marker}" "${log}" 2>/dev/null) -gt 0 ]]; then
    if "${CAPTURE_SCRIPT}" "${CAPTURE_WINDOW_QUERY}" "${screenshot}" > "${OUT_DIR}/${mode}-capture.log" 2>&1; then
      if "${assert_script}" "${screenshot}" > "${screenshot_assertion}" 2>&1; then
        echo "passed" > "${screenshot_status}"
      fi
    fi
  fi

  kill_process_tree "${root_pid}"
  wait "${root_pid}" >/dev/null 2>&1
  set -e
}

summarize_csv() {
  local csv="$1"
  awk -F, '
    NR > 1 {
      key = $1 "," $2
      cpuBySample[key] += $4
      rssBySample[key] += $5
    }
    END {
      for (key in cpuBySample) {
        cpu += cpuBySample[key]
        rss += rssBySample[key]
        if (cpuBySample[key] > maxCpu) maxCpu = cpuBySample[key]
        if (rssBySample[key] > maxRss) maxRss = rssBySample[key]
        count++
      }
      if (count == 0) {
        printf "samples=0 avg_cpu=0 max_cpu=0 avg_rss_kb=0 max_rss_kb=0"
      } else {
        printf "samples=%d avg_cpu=%.2f max_cpu=%.2f avg_rss_kb=%.0f max_rss_kb=%.0f", count, cpu / count, maxCpu, rss / count, maxRss
      }
    }
  ' "${csv}"
}

payload_marker_summary() {
  local marker="$1"
  local log="$2"
  local key="$3"
  awk -v marker="${marker}" -v key="${key}" -v duration="${DURATION_SECONDS}" '
    index($0, marker) {
      frames++
      for (i = 1; i <= NF; i++) {
        if ($i ~ ("^" key "=")) {
          split($i, value, "=")
          payload += value[2]
          if (value[2] > maxPayload) maxPayload = value[2]
        }
      }
    }
    END {
      if (frames == 0) {
        printf "frames=0 fps=0 avg_%s=0 max_%s=0", key, key
      } else {
        printf "frames=%d fps=%.1f avg_%s=%.0f max_%s=%.0f", frames, frames / duration, key, payload / frames, key, maxPayload
      }
    }
  ' "${log}"
}

frame_marker_summary() {
  local marker="$1"
  local log="$2"
  local frames
  frames="$(grep -c "${marker}" "${log}" 2>/dev/null || true)"
  awk -v frames="${frames}" -v duration="${DURATION_SECONDS}" '
    BEGIN {
      if (duration <= 0) {
        printf "frames=%d fps=0", frames
      } else {
        printf "frames=%d fps=%.1f", frames, frames / duration
      }
    }
  '
}

command_recorder_summary() {
  local log="$1"
  awk -v marker="${CMP_COMMAND_RECORDER_MARKER}" -v duration="${DURATION_SECONDS}" '
    index($0, marker) {
      frames++
      frameUnsupported = 0
      for (i = 1; i <= NF; i++) {
        split($i, value, "=")
        if (value[1] == "commands") {
          commands += value[2]
          if (value[2] > maxCommands) maxCommands = value[2]
        } else if (value[1] == "unsupported") {
          frameUnsupported = value[2]
          unsupported += value[2]
          if (value[2] > maxUnsupported) maxUnsupported = value[2]
        } else if (value[2] ~ /^[0-9]+$/) {
          reasons[value[1]] += value[2]
        }
      }
      if (frameUnsupported > 0) unsupportedFrames++
    }
    END {
      if (frames == 0) {
        printf "frames=0 fps=0 avg_commands=0 max_commands=0 unsupported_frames=0 avg_unsupported=0 max_unsupported=0 reasons=none"
        exit
      }
      reasonSummary = "none"
      for (reason in reasons) {
        item = reason ":" reasons[reason]
        reasonSummary = reasonSummary == "none" ? item : reasonSummary "," item
      }
      printf "frames=%d fps=%.1f avg_commands=%.0f max_commands=%.0f unsupported_frames=%d avg_unsupported=%.1f max_unsupported=%.0f reasons=%s",
        frames, frames / duration, commands / frames, maxCommands, unsupportedFrames, unsupported / frames, maxUnsupported, reasonSummary
    }
  ' "${log}"
}

write_report() {
  local report="${OUT_DIR}/report.md"
  local old_summary
  local new_summary
  local old_markers
  local new_markers
  local old_app_frame_summary
  local new_app_frame_summary
  local old_swing_frame_summary
  local new_swing_frame_summary
  local skiko_picture_summary
  local jbr_picture_summary
  local skiko_command_summary
  local jbr_command_summary
  local cmp_command_recorder_summary
  local screenshot_counts
  local screenshot_status

  old_summary="$(summarize_csv "${OUT_DIR}/old-ps.csv")"
  new_summary="$(summarize_csv "${OUT_DIR}/new-ps.csv")"
  old_markers="$(grep -c "${FALLBACK_MARKER}" "${OUT_DIR}/old.log" 2>/dev/null || true)"
  new_markers="$(grep -c "${FALLBACK_MARKER}" "${OUT_DIR}/new.log" 2>/dev/null || true)"
  old_app_frame_summary="$(frame_marker_summary "${APP_FRAME_MARKER}" "${OUT_DIR}/old.log")"
  new_app_frame_summary="$(frame_marker_summary "${APP_FRAME_MARKER}" "${OUT_DIR}/new.log")"
  old_swing_frame_summary="$(frame_marker_summary "${SWING_FRAME_MARKER}" "${OUT_DIR}/old.log")"
  new_swing_frame_summary="$(frame_marker_summary "${SWING_FRAME_MARKER}" "${OUT_DIR}/new.log")"
  skiko_picture_summary="$(payload_marker_summary "${SKIKO_PICTURE_MARKER}" "${OUT_DIR}/new.log" "bytes")"
  jbr_picture_summary="$(payload_marker_summary "${JBR_PICTURE_MARKER}" "${OUT_DIR}/new.log" "bytes")"
  skiko_command_summary="$(payload_marker_summary "${SKIKO_COMMAND_MARKER}" "${OUT_DIR}/new.log" "commands")"
  jbr_command_summary="$(payload_marker_summary "${JBR_COMMAND_MARKER}" "${OUT_DIR}/new.log" "commands")"
  cmp_command_recorder_summary="$(command_recorder_summary "${OUT_DIR}/new.log")"
  screenshot_counts="$(grep -E "${SCREENSHOT_COUNTS_MARKER}|${MIXED_SCREENSHOT_COUNTS_MARKER}|${COMMAND_SCREENSHOT_COUNTS_MARKER}" "${OUT_DIR}/new-screenshot-assertion.log" 2>/dev/null || true)"
  screenshot_status="$(cat "${OUT_DIR}/new-screenshot-status.txt" 2>/dev/null || true)"

  {
    echo "# Magic Jewel JBR Skia Interop Report"
    echo
    echo "- Generated: $(date -Iseconds)"
    echo "- Duration per mode: ${DURATION_SECONDS}s"
    echo "- Startup timeout per mode: ${STARTUP_TIMEOUT_SECONDS}s"
    echo "- Root: ${ROOT_DIR}"
    echo "- SKIKO_VERSION: ${SKIKO_VERSION}"
    echo "- JBR_SKIA_RENDER_MODE: ${JBR_SKIA_RENDER_MODE:-picture}"
    echo "- APP_PROCESS_QUERY: ${APP_PROCESS_QUERY}"
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
    echo "## App Draw Markers"
    echo
    echo "- old: ${old_app_frame_summary}"
    echo "- new: ${new_app_frame_summary}"
    echo
    echo "## Swing Repaint Markers"
    echo
    echo "- old: ${old_swing_frame_summary}"
    echo "- new: ${new_swing_frame_summary}"
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
    echo "## Command Replay Markers"
    echo
    echo "- CMP command recorder: ${cmp_command_recorder_summary}"
    echo "- Skiko command frames: ${skiko_command_summary}"
    echo "- JBR command frames: ${jbr_command_summary}"
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
    echo "CPU and RSS samples are coarse ps samples for the Gradle process tree plus the app process matched by APP_PROCESS_QUERY. They are useful as a smoke signal only, especially on a busy development machine."
    echo "App draw FPS and Skiko/JBR marker FPS count draw/replay calls during the measurement window, not display-presented frames; they can exceed monitor refresh when rendering is not vsync-throttled."
    echo "Picture/command marker counts come from structured Skiko/JBR logs and are the primary signal that the JBR-owned replay path was used."
    echo "The new mode depends on patched local JBR, Skiko, and CMP artifacts; see README.md for the required paths and overrides."
  } > "${report}"

  echo "${report}"
}

run_mode old
run_mode new
write_report
