#/bin/sh

set -v
set -e

# base system
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum install -y epel-release
yum update -y
yum install -y automake make bison pkgconfig wget python3 python3-pip fuse-libs file cmake3 gcc git
mkdir -p /usr/local/bin
ln -s /usr/bin/cmake3 /usr/local/bin/cmake
ln -s /usr/bin/ctest3 /usr/local/bin/ctest

# libevent
wget -O /libevent.tar.gz https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
mkdir /libevent
mkdir /libevent/build
tar xf /libevent.tar.gz --strip-components=1 -C /libevent
cmake3 -S/libevent -B/libevent/build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_STANDARD=99 -DCMAKE_INSTALL_PREFIX=/prefix-libevent -DEVENT__DISABLE_OPENSSL=ON -DEVENT__DISABLE_MBEDTLS=ON -DEVENT__DISABLE_BENCHMARK=ON -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_REGRESS=ON -DEVENT__DISABLE_SAMPLES=ON -DEVENT__DISABLE_DEBUG_MODE=ON -DEVENT__LIBRARY_TYPE=STATIC
make -C/libevent/build -j$(nproc)
make -C/libevent/build install

# utf8proc
wget -O /utf8proc.tar.gz https://github.com/JuliaStrings/utf8proc/archive/refs/tags/v2.9.0.tar.gz
mkdir /utf8proc
mkdir /utf8proc/build
tar xf /utf8proc.tar.gz --strip-components=1 -C /utf8proc
cmake3 -S/utf8proc -B/utf8proc/build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=/prefix-utf8proc
make -C/utf8proc/build -j$(nproc)
make -C/utf8proc/build install

# ncurses
wget -O /ncurses.tar.gz https://invisible-island.net/archives/ncurses/ncurses-6.5.tar.gz
mkdir /ncurses
tar xf /ncurses.tar.gz --strip-components=1 -C /ncurses
mkdir /prefix-ncurses
cd /ncurses
env TERMINFO= TERMINFO_DIRS= ./configure --prefix=/prefix-ncurses --with-termlib --without-shared --enable-pc-files --with-pkg-config-libdir=/prefix-ncurses/pkgconfig
make -j$(nproc)
make install

# appimage
export TMUX_NCURSES_ROOT=/prefix-ncurses
export PKG_CONFIG_PATH=/prefix-libevent/lib/pkgconfig:/prefix-utf8proc/lib64/pkgconfig:/prefix-ncurses/pkgconfig
export LC_CTYPE=en_US.UTF-8
cd /work # should be monted externally
sh autogen.sh
./tools/make_appimage.sh
