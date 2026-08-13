#!/usr/bin/env bash
set -euo pipefail

WRAPPER="/usr/local/sbin/jbr-powermetrics-cpu-gpu"
SUDOERS="/etc/sudoers.d/jbr-skia-powermetrics"
ALLOWED_OUT_ROOT="/Users/seb/src/jbr-skia-zero-copy/magic-jewel/out"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

wrapper_tmp="${tmp_dir}/jbr-powermetrics-cpu-gpu"
sudoers_tmp="${tmp_dir}/jbr-skia-powermetrics"

cat > "${wrapper_tmp}" <<'EOF'
#!/bin/sh
set -eu

allowed_out_root="/Users/seb/src/jbr-skia-zero-copy/magic-jewel/out"

die() {
  echo "jbr-powermetrics-cpu-gpu: $*" >&2
  exit 2
}

if [ "$#" -eq 1 ] && [ "$1" = "--check" ]; then
  exit 0
fi

[ "$#" -eq 6 ] || die "expected: --samplers cpu_power,gpu_power -i <interval-ms> -o <output>"
[ "$1" = "--samplers" ] || die "first argument must be --samplers"
[ "$2" = "cpu_power,gpu_power" ] || die "only cpu_power,gpu_power samplers are allowed"
[ "$3" = "-i" ] || die "third argument must be -i"
case "$4" in
  ''|*[!0-9]*) die "interval must be a positive integer" ;;
esac
[ "$4" -ge 100 ] 2>/dev/null || die "interval must be at least 100 ms"
[ "$4" -le 5000 ] 2>/dev/null || die "interval must be at most 5000 ms"
[ "$5" = "-o" ] || die "fifth argument must be -o"

output="$6"
case "$output" in
  /*) ;;
  *) die "output path must be absolute" ;;
esac

parent="$(dirname "$output")"
[ -d "$parent" ] || die "output parent does not exist: $parent"

allowed_real="$(cd "$allowed_out_root" 2>/dev/null && pwd -P)" || die "allowed output root is missing: $allowed_out_root"
parent_real="$(cd "$parent" 2>/dev/null && pwd -P)" || die "cannot resolve output parent: $parent"

case "$parent_real/" in
  "$allowed_real"/*) ;;
  *) die "output must be under $allowed_real" ;;
esac

[ ! -L "$output" ] || die "output path must not be a symlink"
if [ -e "$output" ] && [ ! -f "$output" ]; then
  die "output path must be a regular file"
fi

exec /usr/bin/powermetrics --samplers "$2" -i "$4" -o "$output"
EOF

cat > "${sudoers_tmp}" <<EOF
# Allow Seb's JBR Skia benchmark harness to collect CPU/GPU powermetrics only
# through the fixed argument-validating wrapper below.
seb ALL=(root) NOPASSWD: ${WRAPPER} *
EOF

chmod 0755 "${wrapper_tmp}"
chmod 0440 "${sudoers_tmp}"

sudo mkdir -p "$(dirname "${WRAPPER}")"
sudo install -o root -g wheel -m 0755 "${wrapper_tmp}" "${WRAPPER}"
sudo install -o root -g wheel -m 0440 "${sudoers_tmp}" "${SUDOERS}"
sudo visudo -cf "${SUDOERS}" >/dev/null

sudo -n "${WRAPPER}" --check >/dev/null

echo "installed ${WRAPPER}"
echo "installed ${SUDOERS}"
echo "verified passwordless wrapper check"
echo
echo "Future runs can use passwordless powermetrics via:"
echo "  POWERMETRICS=${WRAPPER}"
