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
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^skiko_command_frames=1$" "${dir}/summary.properties"
  grep -q "^jbr_command_frames=1$" "${dir}/summary.properties"
  grep -q "^skiko_command_fps=0.1$" "${dir}/summary.properties"
  grep -q "^jbr_command_fps=0.1$" "${dir}/summary.properties"
  grep -q "^old_avg_cpu=0$" "${dir}/summary.properties"
  grep -q "^new_avg_cpu=0$" "${dir}/summary.properties"
}

surface_change_summary_is_machine_readable() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_SURFACE_CHANGED oldContextId=0x1 newContextId=0x1 contextChanged=false surfaceChanged=true oldSurfaceId=0x2 newSurfaceId=0x3 oldMetalTexture=0x4 newMetalTexture=0x5"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}"
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^skiko_surface_change_markers=1$" "${dir}/summary.properties"
}

strict_command_requires_min_surface_changes() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_SURFACE_CHANGED oldContextId=0x1 newContextId=0x1 contextChanged=false surfaceChanged=true oldSurfaceId=0x2 newSurfaceId=0x3 oldMetalTexture=0x4 newMetalTexture=0x5"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_SURFACE_CHANGES=1
}

strict_command_requires_surface_change_shape() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_SURFACE_CHANGED oldContextId=0x1 newContextId=0x1 contextChanged=false surfaceChanged=true oldSurfaceId=0x2 newSurfaceId=0x3 oldMetalTexture=0x4 newMetalTexture=0x5"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true
  grep -q "^skiko_context_change_markers=0$" "${dir}/summary.properties"
  grep -q "^skiko_same_context_surface_change_markers=1$" "${dir}/summary.properties"
}

strict_command_fails_without_expected_surface_change_shape() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_SURFACE_CHANGED oldContextId=0x1 newContextId=0x2 contextChanged=true surfaceChanged=true oldSurfaceId=0x3 newSurfaceId=0x4 oldMetalTexture=0x5 newMetalTexture=0x6"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true 2>/dev/null; then
    echo "Expected strict command validation to fail for wrong surface-change shape" >&2
    return 1
  fi
}

strict_command_fails_without_min_surface_changes() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_SURFACE_CHANGES=1 2>/dev/null; then
    echo "Expected strict command validation to fail below minimum surface-change count" >&2
    return 1
  fi
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
  grep -q "^validation_status=failed$" "${dir}/summary.properties"
  grep -q "validation_failures=.*below expected 1" "${dir}/summary.properties"
}

strict_command_requires_min_paragraph_text_commands() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 paragraphTextCommands=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1
}

strict_command_fails_without_min_paragraph_text_commands() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 paragraphTextCommands=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1 2>/dev/null; then
    echo "Expected strict command validation to fail below minimum paragraph text command count" >&2
    return 1
  fi
}

strict_command_requires_min_image_refs() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageRefs=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_IMAGE_REFS=1
}

strict_command_fails_without_min_image_refs() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageRefs=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_IMAGE_REFS=1 2>/dev/null; then
    echo "Expected strict command validation to fail below minimum image ref count" >&2
    return 1
  fi
}

strict_command_requires_min_image_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageCacheClears=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_IMAGE_CACHE_CLEARS=1
}

strict_command_requires_min_jbr_image_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageCacheClears=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_IMAGE_CACHE_CLEAR backend=native contextId=0x1234 cleared=3"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1
}

strict_command_fails_without_min_jbr_image_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageCacheClears=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 2>/dev/null; then
    echo "Expected strict command validation to fail below minimum JBR image cache clear count" >&2
    return 1
  fi
}

strict_command_requires_min_jbr_scoped_image_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageCacheClears=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_IMAGE_CACHE_CLEAR backend=native contextId=0x1234 cleared=3"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
}

strict_command_fails_without_min_jbr_scoped_image_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageCacheClears=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_IMAGE_CACHE_CLEAR backend=native"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 2>/dev/null; then
    echo "Expected strict command validation to fail below minimum scoped JBR image cache clear count" >&2
    return 1
  fi
}

strict_command_fails_without_min_image_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageCacheClears=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_IMAGE_CACHE_CLEARS=1 2>/dev/null; then
    echo "Expected strict command validation to fail below minimum image cache clear count" >&2
    return 1
  fi
}

strict_command_requires_max_image_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageDefines=0 imageCacheClears=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MAX_IMAGE_DEFINES=0
}

strict_command_fails_above_max_image_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageDefines=1 imageCacheClears=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MAX_IMAGE_DEFINES=0 2>/dev/null; then
    echo "Expected strict command validation to fail above max image define count" >&2
    return 1
  fi
}

strict_command_requires_max_image_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageDefines=0 imageCacheClears=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MAX_IMAGE_CACHE_CLEARS=0
}

strict_command_fails_above_max_image_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageDefines=0 imageCacheClears=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MAX_IMAGE_CACHE_CLEARS=0 2>/dev/null; then
    echo "Expected strict command validation to fail above max image cache clear count" >&2
    return 1
  fi
}

strict_command_requires_min_image_cache_evicts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageCacheEvicts=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_IMAGE_CACHE_EVICTS=1
}

strict_command_requires_min_jbr_image_cache_evicts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 imageCacheEvicts=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_IMAGE_CACHE_EVICT backend=native contextId=0x1234 key=0x5678 removed=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1
}

strict_command_requires_min_popup_frames() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "MAGIC_JEWEL_POPUP_SHOWN x=96 y=214 width=266 height=88"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=1"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=2"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" MAGIC_JEWEL_POPUP_STRESS=true EXPECT_MIN_POPUP_FRAMES=2
  grep -q "^popup_new_shown=1$" "${dir}/summary.properties"
  grep -q "^popup_new_frames=2$" "${dir}/summary.properties"
}

strict_command_fails_without_min_popup_frames() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "MAGIC_JEWEL_POPUP_SHOWN x=96 y=214 width=266 height=88"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=1"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" MAGIC_JEWEL_POPUP_STRESS=true EXPECT_MIN_POPUP_FRAMES=2 2>/dev/null; then
    echo "Expected strict command validation to fail below minimum popup frame count" >&2
    return 1
  fi
  grep -q "^validation_status=failed$" "${dir}/summary.properties"
  grep -q "validation_failures=.*Swing popup paint markers 1 below expected 2" "${dir}/summary.properties"
}

strict_command_requires_popup_window_marker_and_screenshot() {
  local dir
  dir="$(make_report_dir)"
  echo "passed" > "${dir}/new-popup-window-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "MAGIC_JEWEL_POPUP_WINDOW_SHOWN x=96 y=214 width=266 height=88"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=1"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=2"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" MAGIC_JEWEL_POPUP_WINDOW_STRESS=true EXPECT_MIN_POPUP_FRAMES=2
  grep -q "^popup_window_new_shown=1$" "${dir}/summary.properties"
  grep -q "^popup_window_screenshot_status=passed$" "${dir}/summary.properties"
}

strict_command_fails_without_popup_window_screenshot() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "MAGIC_JEWEL_POPUP_WINDOW_SHOWN x=96 y=214 width=266 height=88"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=1"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=2"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" MAGIC_JEWEL_POPUP_WINDOW_STRESS=true EXPECT_MIN_POPUP_FRAMES=2 2>/dev/null; then
    echo "Expected strict command validation to fail without popup window screenshot" >&2
    return 1
  fi
  grep -q "^validation_status=failed$" "${dir}/summary.properties"
  grep -q "validation_failures=.*popup window screenshot assertion did not pass" "${dir}/summary.properties"
}

strict_command_requires_menu_marker_and_min_frames() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "MAGIC_JEWEL_MENU_SHOWN x=96 y=214 width=266 height=88"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=1"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=2"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" MAGIC_JEWEL_MENU_STRESS=true EXPECT_MIN_POPUP_FRAMES=2
  grep -q "^menu_new_shown=1$" "${dir}/summary.properties"
  grep -q "^popup_new_frames=2$" "${dir}/summary.properties"
}

strict_command_fails_without_menu_marker() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=1"
    echo "MAGIC_JEWEL_POPUP_FRAME frame=2"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" MAGIC_JEWEL_MENU_STRESS=true EXPECT_MIN_POPUP_FRAMES=2 2>/dev/null; then
    echo "Expected strict command validation to fail without menu shown marker" >&2
    return 1
  fi
  grep -q "^validation_status=failed$" "${dir}/summary.properties"
  grep -q "validation_failures=.*missing Swing menu shown marker" "${dir}/summary.properties"
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
  grep -q "^cmp_unsupported_reasons=image:1$" "${dir}/summary.properties"
  grep -q "^skiko_picture_frames=1$" "${dir}/summary.properties"
  grep -q "^jbr_picture_frames=1$" "${dir}/summary.properties"
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

abi_mismatch_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=abi-mismatch"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=abi-mismatch
}

native_abi_mismatch_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=native-abi-mismatch"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=native-abi-mismatch
  grep -q "^fallback_new_count=1$" "${dir}/summary.properties"
  grep -q "^skiko_command_frames=0$" "${dir}/summary.properties"
  grep -q "^jbr_command_frames=0$" "${dir}/summary.properties"
}

new_skiko_old_jbr_fallback_matrix_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=native-abi-mismatch"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=native-abi-mismatch
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^fallback_new_count=1$" "${dir}/summary.properties"
  grep -q "^skiko_command_frames=0$" "${dir}/summary.properties"
  grep -q "^jbr_command_frames=0$" "${dir}/summary.properties"
}

old_skiko_new_jbr_without_structured_marker_fails() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=public-api-missing 2>/dev/null; then
    echo "Expected old-Skiko/new-JBR validation to fail without a structured fallback marker" >&2
    return 1
  fi
  grep -q "^validation_status=failed$" "${dir}/summary.properties"
  grep -q "validation_failures=.*missing public-api-missing fallback marker" "${dir}/summary.properties"
}

command_capability_mismatch_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=command-capability-mismatch"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch
}

public_api_missing_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=public-api-missing"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=public-api-missing
}

handshake_fallback_fails_with_command_frames() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=abi-mismatch"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=abi-mismatch 2>/dev/null; then
    echo "Expected handshake fallback validation to fail when command frames are present" >&2
    return 1
  fi
}

strict_command_passes
surface_change_summary_is_machine_readable
strict_command_requires_min_surface_changes
strict_command_requires_surface_change_shape
strict_command_fails_without_expected_surface_change_shape
strict_command_fails_without_min_surface_changes
strict_command_allows_teardown_marker_drift
strict_command_requires_min_text_commands
strict_command_fails_without_min_text_commands
strict_command_requires_min_paragraph_text_commands
strict_command_fails_without_min_paragraph_text_commands
strict_command_requires_min_image_refs
strict_command_fails_without_min_image_refs
strict_command_requires_min_image_cache_clears
strict_command_fails_without_min_image_cache_clears
strict_command_requires_min_jbr_image_cache_clears
strict_command_fails_without_min_jbr_image_cache_clears
strict_command_requires_min_jbr_scoped_image_cache_clears
strict_command_fails_without_min_jbr_scoped_image_cache_clears
strict_command_requires_max_image_defines
strict_command_fails_above_max_image_defines
strict_command_requires_max_image_cache_clears
strict_command_fails_above_max_image_cache_clears
strict_command_requires_min_image_cache_evicts
strict_command_requires_min_jbr_image_cache_evicts
strict_command_requires_min_popup_frames
strict_command_fails_without_min_popup_frames
strict_command_requires_popup_window_marker_and_screenshot
strict_command_fails_without_popup_window_screenshot
strict_command_requires_menu_marker_and_min_frames
strict_command_fails_without_menu_marker
expected_image_fallback_passes
expected_fallback_requires_reason
command_stream_invalid_fallback_passes
abi_mismatch_fallback_passes
native_abi_mismatch_fallback_passes
new_skiko_old_jbr_fallback_matrix_passes
old_skiko_new_jbr_without_structured_marker_fails
command_capability_mismatch_fallback_passes
public_api_missing_fallback_passes
handshake_fallback_fails_with_command_frames

echo "JBR_SKIA_REPORT_VALIDATION_TESTS passed"
