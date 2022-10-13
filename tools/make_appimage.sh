#!/bin/bash

set -e

ROOT_DIR="$(git rev-parse --show-toplevel)"
APP_BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$APP_BUILD_DIR/AppDir"

# All dependencies are located using pkg-config.
# PKG_CONFIG_PATH should be provided externally
# if the dependencies are in a custom location.

# Additionally, TMUX_NCURSES_ROOT pointing to the ncurses installation prefix
# must be provided. This is requred to embed the terminfo database inside the
# appimage.

mkdir -p "$APP_BUILD_DIR"
pushd "$APP_BUILD_DIR"

"$ROOT_DIR/configure" --prefix=/usr --enable-utf8proc

popd

make -C "$APP_BUILD_DIR" -j$(nproc)
make -C "$APP_BUILD_DIR" install DESTDIR="$APP_DIR"

mkdir -p "$APP_DIR/usr/share/metainfo/"
cp "$ROOT_DIR/tools/tmux.appdata.xml" "$APP_DIR/usr/share/metainfo/"

cp -r "$TMUX_NCURSES_ROOT/share/terminfo" "$APP_DIR/usr/share/"

cat << 'EOF' > "$APP_DIR/AppRun"
#!/bin/bash
unset ARGV0
export TERMINFO_DIRS="$APPDIR/usr/share/terminfo:$TERMINFO_DIRS"
exec "$(dirname "$(readlink  -f "${0}")")/usr/bin/tmux" ${@+"$@"}
EOF
chmod 755 "$APP_DIR/AppRun"

# Only downloads linuxdeploy if the remote file is different from local
if [ -e "$APP_BUILD_DIR"/linuxdeploy-x86_64.AppImage ]; then
  curl -Lo "$APP_BUILD_DIR"/linuxdeploy-x86_64.AppImage \
    -z "$APP_BUILD_DIR"/linuxdeploy-x86_64.AppImage \
    https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage  
else
  curl -Lo "$APP_BUILD_DIR"/linuxdeploy-x86_64.AppImage \
    https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
fi

# NOTE: We drop top 2 commits to determine the revision.
TMUX_VERSION="$($APP_BUILD_DIR/tmux -V | cut -d\  -f2-)"
TMUX_REVISION="$(git rev-parse --short HEAD~2)"
export VERSION="$TMUX_VERSION-$TMUX_REVISION"

chmod +x "$APP_BUILD_DIR"/linuxdeploy-x86_64.AppImage
"$APP_BUILD_DIR"/linuxdeploy-x86_64.AppImage \
  --appdir "$APP_DIR" \
  -i "$ROOT_DIR/logo/icons/128x128/tmux.png" \
  -d "$ROOT_DIR/tools/tmux.desktop" \
  --output appimage
