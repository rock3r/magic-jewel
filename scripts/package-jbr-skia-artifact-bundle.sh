#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/out/jbr-skia-artifact-bundles/$(date +%Y%m%d-%H%M%S)}"

DESKTOP_PATCH="${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}"
JBR_API_SHIM="${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}"
JBR_SKIA_LIB="${JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
CMP_OUT="${CMP_OUT:-${ROOT_DIR}/../cmp/out/compose-multiplatform-core}"
COPY_CMP_OUT="${COPY_CMP_OUT:-false}"
ANDROIDX_TRACING_VERSION="${ANDROIDX_TRACING_VERSION:-2.0.0-alpha09}"
ANDROIDX_TRACING_JARS="${ANDROIDX_TRACING_JARS:-}"

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

runtime_jars_in_dir() {
  local dir="$1"
  find "${dir}" -type f -name '*.jar' \
    ! -name '*-sources.jar' \
    ! -name '*-javadoc.jar' \
    2>/dev/null | sort
}

resolved_androidx_tracing_jars() {
  if [[ -n "${ANDROIDX_TRACING_JARS}" ]]; then
    # shellcheck disable=SC2086
    printf '%s\n' ${ANDROIDX_TRACING_JARS}
    return
  fi

  local staged_dir="/tmp/jbr-skia-run/androidx-tracing"
  if [[ -d "${staged_dir}" ]]; then
    runtime_jars_in_dir "${staged_dir}"
    return
  fi

  local module_cache="${HOME}/.gradle/caches/modules-2/files-2.1"
  local coordinates=(
    "androidx.tracing/tracing-desktop/${ANDROIDX_TRACING_VERSION}"
    "androidx.annotation/annotation-jvm/1.7.0"
    "androidx.collection/collection-jvm/1.5.0"
    "org.jetbrains.kotlinx/kotlinx-coroutines-core-jvm/1.9.0"
  )
  local coordinate
  for coordinate in "${coordinates[@]}"; do
    runtime_jars_in_dir "${module_cache}/${coordinate}" | tail -1
  done
}

require_androidx_tracing_jar_set() {
  if [[ "$#" -lt 4 ]]; then
    echo "Missing AndroidX tracing, annotation, collection, and coroutines jars; set ANDROIDX_TRACING_JARS or run rebuild-jbr-skia-local-artifacts.sh first" >&2
    exit 1
  fi
}

require_androidx_tracing_api() {
  local jar
  for jar in "$@"; do
    if jar tf "${jar}" | grep -q '^androidx/tracing/Tracer.class$'; then
      return 0
    fi
  done
  echo "Missing AndroidX tracing API class androidx/tracing/Tracer.class" >&2
  exit 1
}

require_androidx_collection_api() {
  local jar
  for jar in "$@"; do
    if jar tf "${jar}" | grep -q '^androidx/collection/LongObjectMapKt.class$'; then
      return 0
    fi
  done
  echo "Missing AndroidX collection API class androidx/collection/LongObjectMapKt.class" >&2
  exit 1
}

require_dir "desktop patch" "${DESKTOP_PATCH}"
require_file "JBR API shim" "${JBR_API_SHIM}"
require_file "JBR Skia dylib" "${JBR_SKIA_LIB}"
require_dir "CMP output" "${CMP_OUT}"
tracing_jars=()
while IFS= read -r jar; do
  [[ -n "${jar}" ]] && tracing_jars+=("${jar}")
done < <(resolved_androidx_tracing_jars)
require_androidx_tracing_jar_set "${tracing_jars[@]}"
for jar in "${tracing_jars[@]}"; do
  require_file "AndroidX tracing classpath jar" "${jar}"
done
require_androidx_tracing_api "${tracing_jars[@]}"
require_androidx_collection_api "${tracing_jars[@]}"

mkdir -p "${OUT_DIR}"
cp -R "${DESKTOP_PATCH}" "${OUT_DIR}/desktop"
cp "${JBR_API_SHIM}" "${OUT_DIR}/jbr-api-shim.jar"
cp "${JBR_SKIA_LIB}" "${OUT_DIR}/libjbrskiainterop.dylib"
mkdir -p "${OUT_DIR}/androidx-tracing"
bundle_tracing_jars=()
for jar in "${tracing_jars[@]}"; do
  cp "${jar}" "${OUT_DIR}/androidx-tracing/"
  bundle_tracing_jars+=("${OUT_DIR}/androidx-tracing/$(basename "${jar}")")
done

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
androidx_tracing_jars=${bundle_tracing_jars[*]}
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
