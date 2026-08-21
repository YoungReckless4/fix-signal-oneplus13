#!/usr/bin/env sh
# Builds the flashable module zip.
#
# Used by both .github/workflows/release.yml and by hand during development, so
# that what gets tested locally is byte-for-byte what CI publishes.
#
# Usage: ./build.sh [output-dir]
set -eu

SRCDIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="${1:-$SRCDIR/dist}"
STAGE="$OUTDIR/stage"

ID=$(grep -E '^id=' "$SRCDIR/module.prop" | cut -d= -f2-)
VERSION=$(grep -E '^version=' "$SRCDIR/module.prop" | cut -d= -f2-)
ZIP="$OUTDIR/${ID}-${VERSION}.zip"

# Everything the module needs at runtime, plus the licence texts. Repo-only
# files (update.json, .github, build.sh, CHANGELOG.md) stay out of the zip.
PAYLOAD_DIRS="META-INF nvbk"
PAYLOAD_FILES="customize.sh module.prop post-fs-data.sh system.prop LICENSE README.md"

rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE"

for d in $PAYLOAD_DIRS; do cp -r "$SRCDIR/$d" "$STAGE/"; done
for f in $PAYLOAD_FILES; do cp "$SRCDIR/$f" "$STAGE/"; done

# Android's sh chokes on CRLF, and a Windows checkout without .gitattributes
# reintroduces it silently. Fail loudly rather than ship a dead module.
if grep -rlU "$(printf '\r')" \
      "$STAGE/customize.sh" "$STAGE/post-fs-data.sh" \
      "$STAGE/system.prop" "$STAGE/module.prop" "$STAGE/META-INF" 2>/dev/null | grep -q .; then
  echo "ERROR: CRLF line endings in staged payload" >&2
  exit 1
fi

# The image is a fixed-size partition dump; a surprise here means the sync
# picked up something other than a PJZ110 oplusstanvbk partition.
size=$(wc -c < "$STAGE/nvbk/oplusstanvbk.img" | tr -d ' ')
if [ "$size" -ne 1110016 ]; then
  echo "ERROR: unexpected oplusstanvbk.img size $size (expected 1110016)" >&2
  exit 1
fi

if command -v zip >/dev/null 2>&1; then
  ( cd "$STAGE" && zip -qr "$ZIP" . )
elif command -v 7z >/dev/null 2>&1; then
  ( cd "$STAGE" && 7z a -tzip -bso0 -bsp0 "$ZIP" . >/dev/null )
elif [ -x "/c/Program Files/7-Zip/7z.exe" ]; then
  ( cd "$STAGE" && "/c/Program Files/7-Zip/7z.exe" a -tzip -bso0 -bsp0 "$ZIP" . >/dev/null )
else
  echo "ERROR: need either 'zip' or '7z' to build the module archive" >&2
  exit 1
fi

rm -rf "$STAGE"
echo "$ZIP"
