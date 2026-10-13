#!/usr/bin/env bash
#
# Rebuild xgammon-x86_64.AppImage from the original Debian package.
#
# This reproduces the self-contained AppImage committed to this repository.
# It is NOT needed to *use* the package — only to regenerate the AppImage.
#
# Usage:
#   ./scripts/build-appimage.sh /path/to/xgammon_0.98-13_amd64.deb
#
# Requirements: ar, tar, gcc, curl, wget, and a POSIX shell.
# The original Debian package can be fetched from the Debian snapshot archive:
#   https://snapshot.debian.org/package/xgammon/
#
set -euo pipefail

DEB="${1:?usage: $0 <xgammon_0.98-13_amd64.deb>}"
VERSION="0.98"
OUT="xgammon-x86_64.AppImage"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "[*] Working in $WORK"

# --- 1. Extract the Debian package -----------------------------------------
(
  cd "$WORK"
  echo "[*] Unpacking $DEB"
  ar x "$DEB"
  tar -xf data.tar.*
)

# --- 2. Compile the Wayland fix shim ---------------------------------------
echo "[*] Compiling xgammon_fix.so"
gcc -shared -fPIC -o "$WORK/usr/lib/xgammon_fix.so" xgammon_fix.c -ldl

# --- 3. Assemble the AppDir ------------------------------------------------
APPDIR="$WORK/AppDir"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" \
         "$APPDIR/etc/X11/app-defaults" "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/48x48/apps"

cp "$WORK/usr/games/xgammon"                      "$APPDIR/usr/bin/"
cp "$WORK"/usr/lib/x86_64-linux-gnu/libXaw.so.7*  "$APPDIR/usr/lib/"
cp "$WORK"/usr/lib/x86_64-linux-gnu/libXt.so.6*   "$APPDIR/usr/lib/"
cp "$WORK"/usr/lib/x86_64-linux-gnu/libXmu.so.6*  "$APPDIR/usr/lib/"
cp "$WORK"/usr/lib/x86_64-linux-gnu/libXpm.so.4*  "$APPDIR/usr/lib/"
cp "$WORK"/usr/lib/x86_64-linux-gnu/libXext.so.6* "$APPDIR/usr/lib/"
cp "$WORK"/usr/lib/x86_64-linux-gnu/libfl.so.2*   "$APPDIR/usr/lib/"
cp "$WORK"/usr/lib/x86_64-linux-gnu/libbsd.so.0*  "$APPDIR/usr/lib/"
cp "$WORK"/usr/lib/x86_64-linux-gnu/libmd.so.0*   "$APPDIR/usr/lib/"
cp "$WORK/usr/lib/xgammon_fix.so"                 "$APPDIR/usr/lib/"
cp "$WORK/etc/X11/app-defaults/XGammon"           "$APPDIR/etc/X11/app-defaults/"
cp xgammon.png                                    "$APPDIR/xgammon.png"
cp xgammon.png                                    "$APPDIR/usr/share/icons/hicolor/48x48/apps/"

cp xgammon.desktop "$APPDIR/xgammon.desktop" 2>/dev/null || cat > "$APPDIR/xgammon.desktop" <<'EOF'
[Desktop Entry]
Name=xgammon
Comment=Backgammon game for X11
Exec=xgammon
Icon=xgammon
Type=Application
Categories=Game;BoardGame;
Terminal=false
EOF

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
export LD_PRELOAD="$HERE/usr/lib/xgammon_fix.so:$LD_PRELOAD"
export XFILESEARCHPATH="$HERE/etc/X11/app-defaults/%N"
exec "$HERE/usr/bin/xgammon" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# --- 4. Fetch appimagetool and build ---------------------------------------
TOOL="$WORK/appimagetool-x86_64.AppImage"
echo "[*] Downloading appimagetool"
curl -fsSL -o "$TOOL" \
  https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x "$TOOL"

echo "[*] Building $OUT"
ARCH=x86_64 "$TOOL" "$APPDIR" "$OUT"

echo "[+] Done: $OUT ($(du -h "$OUT" | cut -f1))"
sha256sum "$OUT"
