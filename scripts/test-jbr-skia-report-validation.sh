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
    echo "CMP_JBR_COMMAND_RECORDER_OPS fillRect=2 save=1"
    echo "CMP_JBR_COMMAND_RECORDER_OP_WORDS fillRect=14 save=3"
    echo "CMP_JBR_COMMAND_RECORDER_OP_PAIRS fillRect>save=17 save>fillRect=15"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}"
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^skiko_command_frames=1$" "${dir}/summary.properties"
  grep -q "^jbr_command_frames=1$" "${dir}/summary.properties"
  grep -q "^skiko_command_fps=0.1$" "${dir}/summary.properties"
  grep -q "^jbr_command_fps=0.1$" "${dir}/summary.properties"
  grep -q "^cmp_recorder_top_ops=frames=1 top=fillRect:avg=2.0,max=2,total=2,save:avg=1.0,max=1,total=1$" "${dir}/summary.properties"
  grep -q "^cmp_recorder_top_op_words=frames=1 top=fillRect:avg=14.0,max=14,total=14,save:avg=3.0,max=3,total=3$" "${dir}/summary.properties"
  grep -q "^cmp_recorder_top_op_pairs=frames=1 top=fillRect>save:avg=17.0,max=17,total=17,save>fillRect:avg=15.0,max=15,total=15$" "${dir}/summary.properties"
  grep -q "^old_avg_cpu=0$" "${dir}/summary.properties"
  grep -q "^new_avg_cpu=0$" "${dir}/summary.properties"
  grep -q "^host_cpu_count=" "${dir}/summary.properties"
  grep -q "^host_load_1m=" "${dir}/summary.properties"
  grep -q "^host_load_5m=" "${dir}/summary.properties"
  grep -q "^host_load_15m=" "${dir}/summary.properties"
}

report_defaults_to_background_window() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}"
  grep -q "^magic_jewel_background_window=true$" "${dir}/summary.properties"
}

strict_command_requires_min_app_new_frames() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=1"
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=2"
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=3"
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_APP_NEW_FRAMES=3
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^app_new_frames=3$" "${dir}/summary.properties"
}

strict_command_fails_without_min_app_new_frames() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=1"
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_APP_NEW_FRAMES=2 2>/dev/null; then
    echo "Expected strict command validation to fail without enough Magic Jewel Compose frames" >&2
    return 1
  fi
}

strict_command_requires_tiny_full_scene_injection_marker() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=1"
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=2"
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_TINY_FULL_SCENE_INJECTED originalCommands=128"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_TINY_FULL_SCENE_INJECTIONS=1
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^skiko_tiny_full_scene_injections=1$" "${dir}/summary.properties"
}

strict_command_fails_without_tiny_full_scene_injection_marker() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=1"
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=2"
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_TINY_FULL_SCENE_INJECTIONS=1 2>/dev/null; then
    echo "Expected strict command validation to fail without tiny FullScene injection marker" >&2
    return 1
  fi
}

summary_includes_screenshot_counts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"
  {
    echo "JBR_SKIA_COMMAND_SCREENSHOT_COUNTS green=10 topText=20 topTextBox=1,2,3,4 paragraphCentered=30 probeRightDark=40 probeRightShadow=50"
  } > "${dir}/new-screenshot-assertion.log"

  run_validate_only "${dir}"
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^screenshot_green=10$" "${dir}/summary.properties"
  grep -q "^screenshot_topText=20$" "${dir}/summary.properties"
  grep -q "^screenshot_paragraphCentered=30$" "${dir}/summary.properties"
  grep -q "^screenshot_probeRightDark=40$" "${dir}/summary.properties"
  grep -q "^screenshot_probeRightShadow=50$" "${dir}/summary.properties"
  if grep -q "^screenshot_topTextBox=" "${dir}/summary.properties"; then
    echo "Expected screenshot bbox fields to stay out of scalar summary properties" >&2
    return 1
  fi
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

strict_command_requires_min_command_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "SKIKO_JBR_INTEROP_COMMAND_CACHES_CLEARED reason=surfaceChanged"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_COMMAND_CACHE_CLEARS=1
  grep -q "^skiko_command_cache_clear_markers=1$" "${dir}/summary.properties"
}

strict_command_fails_without_min_command_cache_clears() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_COMMAND_CACHE_CLEARS=1 2>/dev/null; then
    echo "Expected strict command validation to fail without command-cache clear markers" >&2
    return 1
  fi
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

strict_command_requires_min_jbr_effect_handle_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_EFFECT_HANDLE_DEFINE backend=java2d contextId=0x1234 handle=0x4567 type=1 version=1 payloadInts=2 legacy=false"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1
  grep -q "^jbr_effect_handle_define_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_min_jbr_effect_handle_evicts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_EFFECT_HANDLE_EVICT backend=java2d contextId=0x1234 handle=0x4567 removed=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_EFFECT_HANDLE_EVICTS=1
  grep -q "^jbr_effect_handle_evict_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_min_jbr_effect_handle_uses() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_EFFECT_HANDLE_USE backend=java2d contextId=0x1234 handle=0x4567 op=47"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1
  grep -q "^jbr_effect_handle_use_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_min_jbr_effect_handle_cache_hits() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_EFFECT_HANDLE_CACHE_HIT backend=java2d contextId=0x1234 handle=0x4567 op=47"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1
  grep -q "^jbr_effect_handle_cache_hit_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_min_jbr_shader_handle_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_SHADER_HANDLE_DEFINE backend=java2d contextId=0x1234 handle=0x4567 type=6 version=1 payloadInts=12"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1
  grep -q "^jbr_shader_handle_define_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_min_jbr_shader_handle_evicts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_SHADER_HANDLE_EVICT backend=java2d contextId=0x1234 handle=0x4567 removed=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_SHADER_HANDLE_EVICTS=1
  grep -q "^jbr_shader_handle_evict_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_min_jbr_shader_handle_uses() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_SHADER_HANDLE_USE backend=java2d contextId=0x1234 handle=0x4567 op=58"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_SHADER_HANDLE_USES=1
  grep -q "^jbr_shader_handle_use_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_min_jbr_shader_handle_cache_hits() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_SHADER_HANDLE_CACHE_HIT backend=java2d contextId=0x1234 handle=0x4567 op=58"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1
  grep -q "^jbr_shader_handle_cache_hit_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_min_jbr_runtime_effect_cache_hits() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_HIT type=shader hash=0x1234 skslLength=64 uniforms=2 children=1"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1
  grep -q "^jbr_runtime_effect_cache_hit_frames=1$" "${dir}/summary.properties"
}

strict_command_fails_without_min_jbr_runtime_effect_cache_hits() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 2>/dev/null; then
    echo "Expected strict command validation to fail without JBR RuntimeEffect source-cache hit markers" >&2
    return 1
  fi
}

strict_command_requires_min_jbr_runtime_effect_cache_evicts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_EVICT type=colorFilter hash=0x5678 skslLength=48 limit=2"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1
  grep -q "^jbr_runtime_effect_cache_evict_frames=1$" "${dir}/summary.properties"
}

strict_command_requires_typed_jbr_runtime_effect_cache_evicts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_EVICT type=shader hash=0x1234 skslLength=52 limit=2"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_EVICT type=colorFilter hash=0x5678 skslLength=48 limit=2"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=shader
  run_validate_only "${dir}" EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=colorFilter
  grep -q "^jbr_runtime_effect_cache_evict_frames=2$" "${dir}/summary.properties"
}

strict_command_fails_without_typed_jbr_runtime_effect_cache_evicts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_EVICT type=colorFilter hash=0x5678 skslLength=48 limit=2"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=shader 2>/dev/null; then
    echo "Expected strict command validation to fail without typed JBR RuntimeEffect source-cache evict markers" >&2
    return 1
  fi
}

strict_command_rejects_unknown_jbr_runtime_effect_cache_evict_type() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_EVICT type=shader hash=0x1234 skslLength=52 limit=2"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=runtimeShader 2>/dev/null; then
    echo "Expected strict command validation to reject unknown JBR RuntimeEffect source-cache evict type" >&2
    return 1
  fi
}

strict_command_fails_without_min_jbr_runtime_effect_cache_evicts() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 2>/dev/null; then
    echo "Expected strict command validation to fail without JBR RuntimeEffect source-cache evict markers" >&2
    return 1
  fi
}

strict_command_requires_max_jbr_runtime_effect_cache_misses() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_MISS type=colorFilter hash=0x5678 skslLength=48 uniforms=1 children=0"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
  grep -q "^jbr_runtime_effect_cache_miss_frames=1$" "${dir}/summary.properties"
}

strict_command_fails_above_max_jbr_runtime_effect_cache_misses() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_MISS type=shader hash=0x1234 skslLength=64 uniforms=2 children=1"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_CACHE_MISS type=shader hash=0x1234 skslLength=64 uniforms=2 children=1"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 2>/dev/null; then
    echo "Expected strict command validation to fail above max JBR RuntimeEffect source-cache miss markers" >&2
    return 1
  fi
}

strict_command_requires_min_jbr_font_data_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_FONT_DATA_DEFINE backend=java2d contextId=0x1234 handle=0x4567 bytes=321"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_FONT_DATA_DEFINES=1
  grep -q "^jbr_font_data_define_frames=1$" "${dir}/summary.properties"
}

strict_command_fails_without_min_jbr_font_data_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_JBR_FONT_DATA_DEFINES=1; then
    echo "Expected strict command validation to fail without JBR font-data define markers" >&2
    return 1
  fi
}

strict_command_requires_max_jbr_font_data_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_FONT_DATA_DEFINE backend=java2d contextId=0x1234 handle=0x4567 bytes=321"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MAX_JBR_FONT_DATA_DEFINES=1
}

strict_command_fails_above_max_jbr_font_data_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_FONT_DATA_DEFINE backend=java2d contextId=0x1234 handle=0x4567 bytes=321"
    echo "JBR_SKIA_INTEROP_FONT_DATA_DEFINE backend=java2d contextId=0x1234 handle=0x4567 bytes=321"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MAX_JBR_FONT_DATA_DEFINES=1 2>/dev/null; then
    echo "Expected strict command validation to fail above max JBR font-data define markers" >&2
    return 1
  fi
}

strict_command_requires_min_jbr_shadow_commands() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_TIMING totalNanos=100 drawNanos=80 flushNanos=10 paragraphCommands=0 paragraphNanos=0 shadowCommands=1"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_JBR_SHADOW_COMMANDS=1
  grep -q "^jbr_shadow_commands_max=1$" "${dir}/summary.properties"
}

strict_command_fails_without_min_jbr_shadow_commands() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_TIMING totalNanos=100 drawNanos=80 flushNanos=10 paragraphCommands=0 paragraphNanos=0 shadowCommands=0"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MIN_JBR_SHADOW_COMMANDS=1 2>/dev/null; then
    echo "Expected strict command validation to fail without enough JBR shadow commands" >&2
    return 1
  fi
}

strict_command_requires_max_jbr_effect_handle_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_EFFECT_HANDLE_DEFINE backend=java2d contextId=0x1234 handle=0x4567 type=1 version=1 payloadInts=2 legacy=false"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
}

strict_command_fails_above_max_jbr_effect_handle_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_EFFECT_HANDLE_DEFINE backend=java2d contextId=0x1234 handle=0x4567 type=1 version=1 payloadInts=2 legacy=false"
    echo "JBR_SKIA_INTEROP_EFFECT_HANDLE_DEFINE backend=java2d contextId=0x1234 handle=0x89ab type=1 version=1 payloadInts=2 legacy=false"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 2>/dev/null; then
    echo "Expected strict command validation to fail above max JBR effect handle define markers" >&2
    return 1
  fi
}

strict_command_requires_max_jbr_shader_handle_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_SHADER_HANDLE_DEFINE backend=java2d contextId=0x1234 handle=0x4567 type=6 version=1 payloadInts=12"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
}

strict_command_fails_above_max_jbr_shader_handle_defines() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_SHADER_HANDLE_DEFINE backend=java2d contextId=0x1234 handle=0x4567 type=6 version=1 payloadInts=12"
    echo "JBR_SKIA_INTEROP_SHADER_HANDLE_DEFINE backend=java2d contextId=0x1234 handle=0x89ab type=6 version=1 payloadInts=12"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1 2>/dev/null; then
    echo "Expected strict command validation to fail above max JBR shader handle define markers" >&2
    return 1
  fi
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

command_recorder_summary_ignores_concatenated_prefix_fields() {
  local dir
  dir="$(make_report_dir)"
  {
    printf '[SKIKO] info: SKIKO_JBR_INTEROP_SCOPE_ACQUIRED abi=106 build=skia=test;abi=106;native=3'
    echo 'CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 textCommands=0 paragraphTextCommands=0 imageDefines=0 imageRefs=1 imageCacheClears=0 imageCacheEvicts=0'
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_IMAGE_REFS=1
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^cmp_unsupported_max=0$" "${dir}/summary.properties"
  grep -q "^cmp_unsupported_reasons=none$" "${dir}/summary.properties"
}

command_recorder_summary_ignores_concatenated_suffix_fields() {
  local dir
  dir="$(make_report_dir)"
  {
    printf 'CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0 textCommands=0 paragraphTextCommands=0 imageDefines=0 imageRefs=1 imageCacheClears=0 imageCacheEvicts=0'
    echo '[SKIKO] info: SKIKO_JBR_INTEROP_SCOPE_ACQUIRED abi=106 build=skia=test;abi=106;native=3 scopeId=99'
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_MIN_IMAGE_REFS=1
  grep -q "^validation_status=passed$" "${dir}/summary.properties"
  grep -q "^cmp_unsupported_max=0$" "${dir}/summary.properties"
  grep -q "^cmp_unsupported_reasons=none$" "${dir}/summary.properties"
}

expected_nested_fallback_reason_passes() {
  local dir
  dir="$(make_report_dir)"
  {
    echo "CMP_JBR_COMMAND_RECORDER_NESTED_UNSUPPORTED commands=42 unsupported=1 sweepGradientStops=1"
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=1 graphicsLayer=1"
    echo "SKIKO_JBR_INTEROP_PICTURE_FRAME bytes=4096 rendered=true"
    echo "JBR_SKIA_INTEROP_PICTURE_FRAME bytes=4096 rendered=true"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=sweepGradientStops
  grep -q "sweepGradientStops:1" "${dir}/summary.properties"
  grep -q "graphicsLayer:1" "${dir}/summary.properties"
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

expected_command_fallback_marker_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=shaderColorFilter"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=command-stream-invalid"
  } > "${dir}/new.log"

  run_validate_only "${dir}" \
    EXPECT_COMMAND_FALLBACK=true \
    EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
    EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=shaderColorFilter"
  grep -q "^expect_command_fallback_marker=SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=shaderColorFilter$" "${dir}/summary.properties"
}

expected_command_fallback_marker_fails_when_missing() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=fillRectColorFilter"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=command-stream-invalid"
  } > "${dir}/new.log"

  if run_validate_only "${dir}" \
      EXPECT_COMMAND_FALLBACK=true \
      EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
      EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=shaderColorFilter" 2>/dev/null; then
    echo "Expected command fallback marker validation to fail without the requested target marker" >&2
    return 1
  fi
  grep -q "^validation_status=failed$" "${dir}/summary.properties"
  grep -q "validation_failures=.*missing expected new-log marker: SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=shaderColorFilter" "${dir}/summary.properties"
}

runtime_effect_compile_failure_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_COMPILE_FAILED hash=0x0123456789abcdef skslLength=42 uniforms=1 children=0 errorLength=17 errorHash=0xfedcba9876543210"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-compile-failed
  grep -q "^jbr_runtime_effect_compile_failures=1$" "${dir}/summary.properties"
}

runtime_color_filter_compile_failure_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "JBR_SKIA_INTEROP_RUNTIME_COLOR_FILTER_COMPILE_FAILED hash=0x0123456789abcdef skslLength=42 uniforms=1 errorLength=17 errorHash=0xfedcba9876543210"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-compile-failed
  grep -q "^jbr_runtime_effect_compile_failures=1$" "${dir}/summary.properties"
}

runtime_effect_build_failure_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_BUILD_FAILED hash=0x0123456789abcdef stage=missing-child nameHash=0xfedcba9876543210 skslLength=42 uniforms=1 children=1 namedUniforms=1 namedChildren=1"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-build-failed EXPECT_RUNTIME_EFFECT_BUILD_FAILURE_STAGE=missing-child
  grep -q "^jbr_runtime_effect_build_failures=1$" "${dir}/summary.properties"
}

runtime_color_filter_child_type_build_failure_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "JBR_SKIA_INTEROP_RUNTIME_COLOR_FILTER_BUILD_FAILED hash=0x0123456789abcdef stage=positional-child-type childIndex=0 skslLength=42 uniforms=1 children=1 namedUniforms=1 namedChildren=1"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-build-failed EXPECT_RUNTIME_EFFECT_BUILD_FAILURE_STAGE=positional-child-type
  grep -q "^jbr_runtime_effect_build_failures=1$" "${dir}/summary.properties"
}

runtime_color_filter_child_count_build_failure_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "JBR_SKIA_INTEROP_RUNTIME_COLOR_FILTER_BUILD_FAILED hash=0x0123456789abcdef stage=child-count skslLength=42 uniforms=1 children=0 namedUniforms=1 namedChildren=0 effectChildren=1"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-build-failed EXPECT_RUNTIME_EFFECT_BUILD_FAILURE_STAGE=child-count
  grep -q "^jbr_runtime_effect_build_failures=1$" "${dir}/summary.properties"
}

runtime_effect_child_type_build_failure_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=false"
    echo "JBR_SKIA_INTEROP_RUNTIME_EFFECT_BUILD_FAILED hash=0x0123456789abcdef stage=child-type nameHash=0xfedcba9876543210 skslLength=42 uniforms=1 children=1 namedUniforms=1 namedChildren=1"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-build-failed EXPECT_RUNTIME_EFFECT_BUILD_FAILURE_STAGE=child-type
  grep -q "^jbr_runtime_effect_build_failures=1$" "${dir}/summary.properties"
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

command_cache_clear_unavailable_fallback_passes() {
  local dir
  dir="$(make_report_dir)"
  rm -f "${dir}/new-screenshot-status.txt"
  {
    echo "MAGIC_JEWEL_COMPOSE_FRAME frame=1"
    echo "CMP_JBR_COMMAND_RECORDER_FRAME commands=21 unsupported=0"
    echo "SKIKO_JBR_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "JBR_SKIA_INTEROP_COMMAND_FRAME commands=21 rendered=true"
    echo "SKIKO_JBR_INTEROP_FALLBACK reason=command-cache-clear-unavailable"
  } > "${dir}/new.log"

  run_validate_only "${dir}" EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-cache-clear-unavailable
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
report_defaults_to_background_window
strict_command_requires_min_app_new_frames
strict_command_fails_without_min_app_new_frames
strict_command_requires_tiny_full_scene_injection_marker
strict_command_fails_without_tiny_full_scene_injection_marker
summary_includes_screenshot_counts
surface_change_summary_is_machine_readable
strict_command_requires_min_surface_changes
strict_command_requires_min_command_cache_clears
strict_command_fails_without_min_command_cache_clears
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
strict_command_requires_min_jbr_effect_handle_defines
strict_command_requires_min_jbr_effect_handle_uses
strict_command_requires_min_jbr_effect_handle_evicts
strict_command_requires_min_jbr_effect_handle_cache_hits
strict_command_requires_min_jbr_shader_handle_defines
strict_command_requires_min_jbr_shader_handle_uses
strict_command_requires_min_jbr_shader_handle_evicts
strict_command_requires_min_jbr_shader_handle_cache_hits
strict_command_requires_min_jbr_runtime_effect_cache_hits
strict_command_fails_without_min_jbr_runtime_effect_cache_hits
strict_command_requires_min_jbr_runtime_effect_cache_evicts
strict_command_requires_typed_jbr_runtime_effect_cache_evicts
strict_command_fails_without_typed_jbr_runtime_effect_cache_evicts
strict_command_rejects_unknown_jbr_runtime_effect_cache_evict_type
strict_command_fails_without_min_jbr_runtime_effect_cache_evicts
strict_command_requires_max_jbr_runtime_effect_cache_misses
strict_command_fails_above_max_jbr_runtime_effect_cache_misses
strict_command_requires_min_jbr_font_data_defines
strict_command_fails_without_min_jbr_font_data_defines
strict_command_requires_max_jbr_font_data_defines
strict_command_fails_above_max_jbr_font_data_defines
strict_command_requires_min_jbr_shadow_commands
strict_command_fails_without_min_jbr_shadow_commands
strict_command_requires_max_jbr_effect_handle_defines
strict_command_fails_above_max_jbr_effect_handle_defines
strict_command_requires_max_jbr_shader_handle_defines
strict_command_fails_above_max_jbr_shader_handle_defines
strict_command_requires_min_popup_frames
strict_command_fails_without_min_popup_frames
strict_command_requires_popup_window_marker_and_screenshot
strict_command_fails_without_popup_window_screenshot
strict_command_requires_menu_marker_and_min_frames
strict_command_fails_without_menu_marker
expected_image_fallback_passes
command_recorder_summary_ignores_concatenated_prefix_fields
command_recorder_summary_ignores_concatenated_suffix_fields
expected_nested_fallback_reason_passes
expected_fallback_requires_reason
command_stream_invalid_fallback_passes
expected_command_fallback_marker_passes
expected_command_fallback_marker_fails_when_missing
runtime_effect_compile_failure_fallback_passes
runtime_color_filter_compile_failure_fallback_passes
runtime_effect_build_failure_fallback_passes
runtime_color_filter_child_count_build_failure_fallback_passes
runtime_color_filter_child_type_build_failure_fallback_passes
runtime_effect_child_type_build_failure_fallback_passes
abi_mismatch_fallback_passes
native_abi_mismatch_fallback_passes
new_skiko_old_jbr_fallback_matrix_passes
old_skiko_new_jbr_without_structured_marker_fails
command_capability_mismatch_fallback_passes
public_api_missing_fallback_passes
command_cache_clear_unavailable_fallback_passes
handshake_fallback_fails_with_command_frames

echo "JBR_SKIA_REPORT_VALIDATION_TESTS passed"
