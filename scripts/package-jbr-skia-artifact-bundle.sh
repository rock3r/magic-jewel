#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/out/jbr-skia-artifact-bundles/$(date +%Y%m%d-%H%M%S)}"

DESKTOP_PATCH="${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}"
JBR_API_SHIM="${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}"
JBR_SKIA_LIB="${JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
CMP_OUT="${CMP_OUT:-/Users/rock3r/src/cmp-jbr-skia-poc/out/compose-multiplatform-core}"
COPY_CMP_OUT="${COPY_CMP_OUT:-false}"

require_file() {
  local label="$1"
  local path="$2"
  if [[ ! -f "${path}" ]]; then
    echo "Missing ${label}: ${path}" >&2
    exit 1
  fi
}

require_dir() {
  local label="$1"
  local path="$2"
  if [[ ! -d "${path}" ]]; then
    echo "Missing ${label}: ${path}" >&2
    exit 1
  fi
}

require_dir "desktop patch" "${DESKTOP_PATCH}"
require_file "JBR API shim" "${JBR_API_SHIM}"
require_file "JBR Skia dylib" "${JBR_SKIA_LIB}"
require_dir "CMP output" "${CMP_OUT}"

mkdir -p "${OUT_DIR}"
cp -R "${DESKTOP_PATCH}" "${OUT_DIR}/desktop"
cp "${JBR_API_SHIM}" "${OUT_DIR}/jbr-api-shim.jar"
cp "${JBR_SKIA_LIB}" "${OUT_DIR}/libjbrskiainterop.dylib"

bundle_cmp_out="${CMP_OUT}"
if [[ "${COPY_CMP_OUT}" == "true" ]]; then
  cp -R "${CMP_OUT}" "${OUT_DIR}/compose-multiplatform-core"
  bundle_cmp_out="${OUT_DIR}/compose-multiplatform-core"
fi

cat > "${OUT_DIR}/manifest.properties" <<EOF_MANIFEST
schema_version=1
created_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
desktop_patch=${OUT_DIR}/desktop
jbr_api_shim=${OUT_DIR}/jbr-api-shim.jar
jbr_skia_lib=${OUT_DIR}/libjbrskiainterop.dylib
skiko_version=${SKIKO_VERSION}
cmp_out=${bundle_cmp_out}
cmp_out_copied=${COPY_CMP_OUT}
source_desktop_patch=${DESKTOP_PATCH}
source_jbr_api_shim=${JBR_API_SHIM}
source_jbr_skia_lib=${JBR_SKIA_LIB}
source_cmp_out=${CMP_OUT}
EOF_MANIFEST

cat > "${OUT_DIR}/use-as-old.env" <<EOF_ENV
OLD_ARTIFACT_BUNDLE=${OUT_DIR}
EOF_ENV

echo "JBR_SKIA_ARTIFACT_BUNDLE created bundle=${OUT_DIR}"
echo "manifest=${OUT_DIR}/manifest.properties"
