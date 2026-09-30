#!/bin/sh
# Behaviour tests for scripts/install.sh checksum handling (issue #30).
#
# Builds a fake release (a stub tarball whose clippy-pet echoes its arguments,
# plus SHA256SUMS) and a stub curl that serves it, then runs the real
# install.sh in remote mode through five cases, including the abuse case:
# --skip-verify must never let a tampered download through.
#
# Usage: tests/install-sh.sh [SHELL]   (default: dash if installed, else sh)
# Linux only (the checksum-free PATH is built from coreutils binaries).
set -u

ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
# Resolve to an absolute path: the checksum-free PATH below won't contain it.
RUN_SHELL=$(command -v "${1:-dash}" || command -v sh)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
failures=0

pass() { printf 'ok   %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; failures=$((failures + 1)); }

# The installer runs from outside a checkout, so it takes the remote path.
mkdir -p "$WORK/standalone" "$WORK/rel/clippy-pet-9.9.9/bin" "$WORK/bin" "$WORK/nosha" "$WORK/home"
cp "$ROOT/scripts/install.sh" "$WORK/standalone/install.sh"
cat > "$WORK/rel/clippy-pet-9.9.9/bin/clippy-pet" <<'EOF'
#!/bin/sh
echo "STUB clippy-pet called with: $*"
EOF
chmod +x "$WORK/rel/clippy-pet-9.9.9/bin/clippy-pet"

cat > "$WORK/bin/curl" <<EOF
#!/bin/sh
# -fsSI: answer the "latest release" redirect; -o FILE URL: copy from the fake release.
case "\$*" in *-fsSI*) printf 'Location: https://github.com/x/releases/tag/v9.9.9\\r\\n'; exit 0 ;; esac
out=; url=
while [ \$# -gt 0 ]; do [ "\$1" = -o ] && { out=\$2; shift; }; url=\$1; shift; done
cp "$WORK/rel/\${url##*/}" "\$out"
EOF
chmod +x "$WORK/bin/curl"

# A PATH with everything install.sh needs except sha256sum and shasum.
for tool in sh dash tar gzip awk grep sed mktemp rm find head tr cat dirname mkdir cp chmod env; do
    path=$(command -v "$tool") && ln -sf "$path" "$WORK/nosha/$tool"
done
ln -sf "$WORK/bin/curl" "$WORK/nosha/curl"
FULL_PATH="$WORK/bin:/usr/bin:/bin"

build_release() {
    (cd "$WORK/rel" && rm -f clippy-pet-9.9.9.tar.gz \
        && tar -czf clippy-pet-9.9.9.tar.gz clippy-pet-9.9.9 \
        && sha256sum clippy-pet-9.9.9.tar.gz > SHA256SUMS)
}

# run PATH ARGS... -> sets $status and $output
run() {
    path=$1
    shift
    output=$(env -i HOME="$WORK/home" TMPDIR="$WORK" PATH="$path" "$RUN_SHELL" "$WORK/standalone/install.sh" "$@" 2>&1)
    status=$?
}

build_release

run "$WORK/nosha" --quiet
if [ "$status" -eq 1 ] && printf '%s' "$output" | grep -q 'neither sha256sum nor shasum' \
    && ! printf '%s' "$output" | grep -q 'STUB'; then
    pass "no checksum tool: refuses and names the tools"
else
    fail "no checksum tool: expected exit 1 and no install (status $status): $output"
fi

run "$WORK/nosha" --skip-verify --quiet
if [ "$status" -eq 0 ] && printf '%s' "$output" | grep -q 'installing .* unverified' \
    && printf '%s' "$output" | grep -qx 'STUB clippy-pet called with: install --quiet'; then
    pass "no checksum tool + --skip-verify: warns, installs, flag not forwarded"
else
    fail "no checksum tool + --skip-verify (status $status): $output"
fi

run "$FULL_PATH" --quiet
if [ "$status" -eq 0 ] && printf '%s' "$output" | grep -qx 'STUB clippy-pet called with: install --quiet'; then
    pass "checksum tool present: installs as before"
else
    fail "checksum tool present (status $status): $output"
fi

echo junk >> "$WORK/rel/clippy-pet-9.9.9.tar.gz"

run "$FULL_PATH"
if [ "$status" -eq 1 ] && printf '%s' "$output" | grep -q 'checksum mismatch' \
    && ! printf '%s' "$output" | grep -q 'STUB'; then
    pass "tampered tarball: refused"
else
    fail "tampered tarball (status $status): $output"
fi

run "$FULL_PATH" --skip-verify
if [ "$status" -eq 1 ] && printf '%s' "$output" | grep -q 'checksum mismatch' \
    && ! printf '%s' "$output" | grep -q 'STUB'; then
    pass "tampered tarball + --skip-verify: still refused"
else
    fail "tampered tarball + --skip-verify must not install (status $status): $output"
fi

if [ "$failures" -gt 0 ]; then
    printf '%d failure(s) under %s\n' "$failures" "$RUN_SHELL"
    exit 1
fi
printf 'all install.sh checks passed under %s\n' "$RUN_SHELL"
