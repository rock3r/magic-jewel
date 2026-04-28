#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPORT_SCRIPT="${SCRIPT_DIR}/jbr-skia-interop-report.sh"

make_report_dir() {
  local dir
  dir="$(mktemp -d "${TMPDIR:-/tmp}/magic-jewel-report-validation.XXXXXX")"
  : > "${dir}/report.md"
  echo "passed" > "${dir}/new-screenshot-status.txt"
  echo "${dir}"
}

run_validate_only() {
  local dir="$1"
  shift
  OUT_DIR="${dir}" \
    JBR_SKIA_RENDER_MODE=commands \
    EXPECT_STRICT_COMMANDS=true \
    env "$@" \
    "${REPORT_SCRIPT}" --validate-only >/dev/null
}

strict_command_passes() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}"
}

strict_command_allows_teardown_marker_drift() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}"
}

strict_command_requires_min_text_commands() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 textCommands=8"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_TEXT_COMMANDS=8
}

strict_command_fails_without_min_text_commands() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 textCommands=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_TEXT_COMMANDS=1 2>/dev/null; then
    echo "Expected strict command validation to fail below minimum text command count" >&2
    return 1
  fi
}

expected_image_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=1 image=1"
    echo "SKIKO_JBR_INTEROP_PICTURE_FRAME bytes=4096 rendered=true"
    echo "JBR_SKIA_INTEROP_PICTURE_FRAME bytes=4096 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=image
}

expected_fallback_requires_reason() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=1 text=1"
    echo "SKIKO_JBR_INTEROP_PICTURE_FRAME bytes=4096 rendered=true"
    echo "JBR_SKIA_INTEROP_PICTURE_FRAME bytes=4096 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=image 2>/dev/null; then
    echo "Expected image fallback validation to fail without image reason" >&2
    return 1
  fi
}

command_stream_invalid_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=command-stream-invalid"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid
}

strict_command_passes
strict_command_allows_teardown_marker_drift
strict_command_requires_min_text_commands
strict_command_fails_without_min_text_commands
expected_image_fallback_passes
expected_fallback_requires_reason
command_stream_invalid_fallback_passes

echo "JBR_SKIA_REPORT_VALIDATION_TESTS passed"
