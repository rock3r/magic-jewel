#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
WORKSPACE_ROOT="$(cd -- "${SCRIPT_DIR}/../.." >/dev/null && pwd)"

JBR_ROOT="${JBR_ROOT:-${WORKSPACE_ROOT}/jbr}"
REBUILD_LOCAL_ARTIFACTS="${REBUILD_LOCAL_ARTIFACTS:-true}"
OUT_ROOT="${OUT_ROOT:-/tmp/jbr-skia-run}"
DESKTOP_PATCH_DIR="${DESKTOP_PATCH_DIR:-${OUT_ROOT}/desktop}"
STUB_SRC_DIR="${STUB_SRC_DIR:-${OUT_ROOT}/stub-src}"
NATIVE_OUT_DIR="${NATIVE_OUT_DIR:-/tmp/jbr-skia-native}"
NATIVE_LIB="${NATIVE_LIB:-${NATIVE_OUT_DIR}/libjbrskiainterop.dylib}"
TEST_CLASSES_DIR="${TEST_CLASSES_DIR:-/tmp/jbr-skia-api-test-classes}"

require_file() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    echo "Required file missing: ${path}" >&2
    exit 1
  fi
}

require_dir() {
  local path="$1"
  if [[ ! -d "${path}" ]]; then
    echo "Required directory missing: ${path}" >&2
    exit 1
  fi
}

safe_recreate_dir() {
  local path="$1"
  case "${path}" in
    /tmp/jbr-skia-api-test-classes|/private/tmp/jbr-skia-api-test-classes|/tmp/jbr-skia-api-test-classes/*|/private/tmp/jbr-skia-api-test-classes/*)
      rm -rf "${path}"
      mkdir -p "${path}"
      ;;
    *)
      echo "Refusing to recreate non-temporary test output directory: ${path}" >&2
      exit 1
      ;;
  esac
}

if [[ "${REBUILD_LOCAL_ARTIFACTS}" == "true" ]]; then
  echo "== Rebuild local JBR Skia artifacts =="
  "${SCRIPT_DIR}/rebuild-jbr-skia-local-artifacts.sh"
fi

require_dir "${DESKTOP_PATCH_DIR}"
require_dir "${STUB_SRC_DIR}"
require_file "${STUB_SRC_DIR}/com/jetbrains/exported/JBRApi.java"
require_file "${NATIVE_LIB}"
require_file "${JBR_ROOT}/test/jdk/jb/JBRSkia/JBRSkiaApiTest.java"

echo "== Patch temporary JBRApi stub into java.desktop overlay =="
javac \
  -d "${DESKTOP_PATCH_DIR}" \
  "${STUB_SRC_DIR}/com/jetbrains/exported/JBRApi.java"

echo "== Compile JBRSkiaApiTest =="
safe_recreate_dir "${TEST_CLASSES_DIR}"
javac \
  --patch-module "java.desktop=${DESKTOP_PATCH_DIR}" \
  --add-exports java.desktop/com.jetbrains.desktop=ALL-UNNAMED \
  -d "${TEST_CLASSES_DIR}" \
  "${STUB_SRC_DIR}/com/jetbrains/exported/JBRApi.java" \
  "${JBR_ROOT}/test/jdk/jb/JBRSkia/JBRSkiaApiTest.java"

echo "== Run JBRSkiaApiTest =="
java \
  -Djava.awt.headless=true \
  -Dsun.java2d.skia.interop.library="${NATIVE_LIB}" \
  --patch-module "java.desktop=${DESKTOP_PATCH_DIR}" \
  --add-exports java.desktop/com.jetbrains.desktop=ALL-UNNAMED \
  --add-exports java.desktop/com.jetbrains.exported=ALL-UNNAMED \
  -cp "${TEST_CLASSES_DIR}" \
  JBRSkiaApiTest

echo "JBR_SKIA_API_TEST passed"
