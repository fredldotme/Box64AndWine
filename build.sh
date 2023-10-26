#/bin/bash

set -e
set -x

SRC_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SRC_PATH

if [ "$SNAPCRAFT_PART_INSTALL" != "" ]; then
    INSTALL=$SNAPCRAFT_PART_INSTALL
elif [ "$INSTALL_DIR" != "" ]; then
    INSTALL=$INSTALL_DIR
fi

if [ "$BUILD_DIR" == "" ]; then
    BUILD_DIR="$INSTALL"
fi

if [ "$SNAPCRAFT_ARCH_TRIPLET" != "" ]; then
    ARCH_TRIPLET="$SNAPCRAFT_ARCH_TRIPLET"
fi

if [ -f /usr/bin/python3.8 ]; then
    PYTHON_BIN=/usr/bin/python3.8
elif [ -f /usr/bin/python3.6 ]; then
    PYTHON_BIN=/usr/bin/python3.6
fi

if [ "$PYTHON_BIN" == "" ]; then
    echo "PYTHON_BIN not found, bailing..."
fi

if [ "$INSTALL" == "" ]; then
    echo "Cannot find INSTALL, bailing..."
    exit 1
fi

# Argument variables
CLEAN=0
LEGACY=0

# Internal variables
if [ -f /usr/bin/dpkg-architecture ]; then
    MULTIARCH=$(/usr/bin/dpkg-architecture -qDEB_TARGET_MULTIARCH)
else
    MULTIARCH=""
fi

# pkg-config & m4 macros
PKG_CONF_SYSTEM=/usr/lib/$MULTIARCH/pkgconfig
PKG_CONF_INSTALL=$INSTALL/lib/pkgconfig:$INSTALL/share/pkgconfig:$INSTALL/lib/$MULTIARCH/pkgconfig
PKG_CONF_EXIST=$PKG_CONFIG_PATH
PKG_CONFIG_PATH=$PKG_CONF_INSTALL:$PKG_CONF_SYSTEM
if [ "$PKG_CONF_EXIST" != "" ]; then
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PKG_CONF_EXIST"
fi
ACLOCAL_PATH=$INSTALL/share/aclocal

# Overridable number of build processors
if [ "$NUM_PROCS" == "" ]; then
    NUM_PROCS=$(nproc --all)
fi

# Argument parsing
while [[ $# -gt 0 ]]; do
    arg="$1"
    case $arg in
        -c|--clean)
            CLEAN=1
            shift
        ;;
        -l|--legacy)
            LEGACY=1
            shift
        ;;
        *)
            echo "usage: $0 [-c|--clean]"
            exit 1
        ;;
    esac
done

function build_3rdparty_autogen {
    echo "Building: $1"
    cd $SRC_PATH
    cd 3rdparty/$1
    if [ ! -f "$BUILD_DIR/.${1}_built" ]; then
        if [ -f ./autogen.sh ]; then
            env PKG_CONFIG_PATH=$PKG_CONFIG_PATH ACLOCAL_PATH=$ACLOCAL_PATH LD_LIBRARY_PATH=$INSTALL/lib:$LD_LIBRARY_PATH ./autogen.sh --prefix=$INSTALL $2
        fi
        env PKG_CONFIG_PATH=$PKG_CONFIG_PATH ACLOCAL_PATH=$ACLOCAL_PATH LD_LIBRARY_PATH=$INSTALL/lib:$LD_LIBRARY_PATH ./configure --prefix=$INSTALL $2
        make VERBOSE=1 -j$NUM_PROCS
    fi
    if [ -f /usr/bin/sudo ]; then
        sudo make install -j$NUM_PROCS
    else
        make install -j$NUM_PROCS
    fi
}

function build_cmake {
    if [ "$CLEAN" == "1" ]; then
        if [ -d build ]; then
            rm -rf build
        fi
    fi
    if [ ! -d build ]; then
        mkdir build
    fi
    cd build
    if [ ! -f "$BUILD_DIR/.${1}_built" ]; then
        env PKG_CONFIG_PATH=$PKG_CONFIG_PATH LD_LIBRARY_PATH=$INSTALL/lib:$LD_LIBRARY_PATH LDFLAGS="-L$INSTALL/lib" \
            cmake .. \
            -DCMAKE_INSTALL_PREFIX=$INSTALL \
            -DCMAKE_MODULE_PATH=$INSTALL \
            -DCMAKE_CXX_FLAGS="-isystem $INSTALL/include -L$INSTALL/lib -Wno-deprecated-declarations -Wno-missing-include-dirs -Wl,-rpath-link,$INSTALL/lib" \
            -DCMAKE_C_FLAGS="-isystem $INSTALL/include -L$INSTALL/lib -Wno-deprecated-declarations -Wno-missing-include-dirs -Wl,-rpath-link,$INSTALL/lib" \
            -DCMAKE_LD_FLAGS="-L$INSTALL/lib" \
            -DCMAKE_LIBRARY_PATH=$INSTALL/lib $@
        make VERBOSE=1 -j$NUM_PROCS
    fi

    if [ -f /usr/bin/sudo ]; then
        sudo make install -j$NUM_PROCS
    else
        make install -j$NUM_PROCS
    fi
}

function build_3rdparty_cmake {
    echo "Building: $1"
    cd $SRC_PATH
    cd 3rdparty/$1
    build_cmake "$2"
}

function build_cmake_sysroot {
    if [ "$CLEAN" == "1" ]; then
        if [ -d build ]; then
            rm -rf build
        fi
    fi
    if [ ! -d build ]; then
        mkdir build
    fi
    cd build
    if [ ! -f "$BUILD_DIR/.${1}_built" ]; then
        env PKG_CONFIG_PATH=$PKG_CONFIG_PATH LD_LIBRARY_PATH=$INSTALL/lib:$LD_LIBRARY_PATH LDFLAGS="-L$INSTALL/lib" \
            cmake .. \
            -DCMAKE_INSTALL_PREFIX=$INSTALL \
            -DCMAKE_MODULE_PATH=$INSTALL \
            -DCMAKE_CXX_FLAGS="-isystem $INSTALL/sysroot/armhf/usr/include -L$INSTALL/sysroot/armhf/usr/lib -L$INSTALL/sysroot/armhf/usr/lib/arm-linux-gnueabihf -Wno-deprecated-declarations -Wl,-rpath-link,$BUILD_DIR/sysroot/armhf/usr/lib" \
            -DCMAKE_C_FLAGS="-isystem $INSTALL/sysroot/armhf/usr/include -L$INSTALL/sysroot/armhf/usr/lib -L$INSTALL/sysroot/armhf/usr/lib/arm-linux-gnueabihf -Wno-deprecated-declarations -Wl,-rpath-link,$INSTALL/sysroot/armhf/usr/lib" \
            -DCMAKE_LD_FLAGS="-L$INSTALL/sysroot/armhf/usr/lib -L$INSTALL/sysroot/armhf/usr/lib/arm-linux-gnueabihf" \
            -DCMAKE_LIBRARY_PATH=$INSTALL/sysroot/armhf/usr/lib $@
        make VERBOSE=1 -j$NUM_PROCS
    fi

    if [ -f /usr/bin/sudo ]; then
        sudo make install -j$NUM_PROCS
    else
        make install -j$NUM_PROCS
    fi
}

function build_3rdparty_cmake_sysroot {
    echo "Building: $1"
    cd $SRC_PATH
    cd 3rdparty/$1
    build_cmake_sysroot "$2"
}

function build_wrappers {
    echo "Building wrappers ($1)"
    cd $SRC_PATH
    cd src/wrappers/$1
    build_cmake $2
}

function build_project {
    echo "Building project"
    cd $SRC_PATH
    cd src
    build_cmake $2
}

# Use ccache as much as possible
export CCACHE_DIR=$BUILD_DIR/ccache
export PATH=/usr/lib/ccache:$PATH

# Commonly used armhf cross-build CMake arguments
CMAKE_ARMHF_ARGS="-DCMAKE_C_COMPILER=/usr/bin/arm-linux-gnueabihf-gcc -DCMAKE_CXX_COMPILER=/usr/bin/arm-linux-gnueabihf-g++ -DCMAKE_AR=/usr/bin/arm-linux-gnueabihf-ar -DCMAKE_LINKER=/usr/bin/arm-linux-gnueabihf-ld -DCMAKE_RANLIB=/usr/bin/arm-linux-gnueabihf-ranlib"

# Fetch & create armhf sysroot
if [ "$CLEAN" == "1" ]; then
    if [ -d $BUILD_DIR/sysroot/armhf ]; then
        rm -rf $BUILD_DIR/sysroot/armhf
    fi
fi
mkdir -p $BUILD_DIR/sysroot/armhf
mkdir -p $INSTALL/sysroot/armhf

# armhf for box86 libraries
wget -O $BUILD_DIR/sysroot/armhf.tar.gz https://ci.ubports.com/job/focal-hybris-rootfs-arm64/job/master/lastSuccessfulBuild/artifact/ubuntu-touch-hybris-rootfs-armhf.tar.gz
tar xvf $BUILD_DIR/sysroot/armhf.tar.gz -C $INSTALL/sysroot/armhf

if [ "$CLEAN" == "1" ]; then
    if [ -d $INSTALL/sysroot/amd64 ]; then
        rm -rf $INSTALL/sysroot/amd64
    fi
fi
mkdir -p $INSTALL/sysroot/amd64
mkdir -p $INSTALL/sysroot/amd64

# base amd64 for BOX64_BASH and some emulation bits
wget -O $BUILD_DIR/sysroot/amd64.tar.gz https://cdimage.ubuntu.com/ubuntu-base/releases/focal/release/ubuntu-base-20.04.5-base-amd64.tar.gz
tar xvf $BUILD_DIR/sysroot/amd64.tar.gz -C $INSTALL/sysroot/amd64

# Build pe-parse
build_3rdparty_cmake pe-parse

# Build main 64bit sources
build_project
build_wrappers x86_64

# Build SDL
#build_3rdparty_cmake SDL "-DSDL_SHARED_ENABLED_BY_DEFAULT=ON"
#build_3rdparty_cmake SDL_image "-DSDL2IMAGE_VENDORED=ON"
#build_3rdparty_cmake SDL_mixer "-DSDL2MIXER_VENDORED=ON"

# x86_64 support with OpenGL
build_3rdparty_cmake gl4es "-DGLVND=OFF -DHYBRIS=ON -DNOX11=OFF -DNOEGL=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMULTIARCH_PREFIX=aarch64-linux-gnu"
build_3rdparty_cmake box64 "-DGENERIC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo"

# glvnd-compatible naming
# mv $INSTALL/usr/lib/aarch64-linux-gnu/gl4es/libGL.so.1 $INSTALL/usr/lib/aarch64-linux-gnu/gl4es/libGLX_gl4es.so.0  

# Requirements for compilation
cd $BUILD_DIR
wget http://ports.ubuntu.com/pool/main/libx/libx11/libx11-6_1.6.9-2ubuntu1.6_armhf.deb
wget http://ports.ubuntu.com/pool/main/libx/libx11/libx11-dev_1.6.9-2ubuntu1.6_armhf.deb

# Mostly runtime libs for better app support (GTK, Steam)
wget http://ports.ubuntu.com/pool/universe/liba/libappindicator/libappindicator1_12.10.1+20.04.20200408.1-0ubuntu1_armhf.deb
wget http://ports.ubuntu.com/pool/main/liba/libappindicator/libappindicator3-1_12.10.1+20.04.20200408.1-0ubuntu1_armhf.deb
wget http://ports.ubuntu.com/pool/main/libd/libdbusmenu/libdbusmenu-glib4_16.04.1+18.10.20180917-0ubuntu6_armhf.deb
wget http://ports.ubuntu.com/pool/main/libd/libdbusmenu/libdbusmenu-gtk3-4_16.04.1+18.10.20180917-0ubuntu6_armhf.deb
wget http://ports.ubuntu.com/pool/universe/libd/libdbusmenu/libdbusmenu-gtk4_16.04.1+18.10.20180917-0ubuntu6_armhf.deb
wget http://ports.ubuntu.com/pool/universe/libs/libsdl1.2/libsdl1.2debian_1.2.15+dfsg2-5_armhf.deb
wget http://ports.ubuntu.com/pool/main/g/gtk+2.0/libgtk2.0-bin_2.24.32-4ubuntu4_armhf.deb
wget http://ports.ubuntu.com/pool/main/g/gtk+2.0/gtk2-engines-pixbuf_2.24.32-4ubuntu4_armhf.deb
wget http://ports.ubuntu.com/pool/main/g/gtk+2.0/libgtk2.0-0_2.24.32-4ubuntu4_armhf.deb
wget http://ports.ubuntu.com/pool/main/g/gtk+2.0/libgtk2.0-common_2.24.32-4ubuntu4_all.deb

for f in $(ls *.deb); do dpkg -x $f $BUILD_DIR/sysroot/tmp; done
cp -a $BUILD_DIR/sysroot/tmp/* $INSTALL/sysroot/armhf
rm -rf $BUILD_DIR/sysroot/tmp

# Build wrappers for i386
build_wrappers i386 "$CMAKE_ARMHF_ARGS"

# Build SDL
#build_3rdparty_cmake_sysroot SDL "-DSDL_SHARED_ENABLED_BY_DEFAULT=ON -DCMAKE_FIND_ROOT_PATH=$INSTALL/sysroot/armhf -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY $CMAKE_ARMHF_ARGS"
#build_3rdparty_cmake_sysroot SDL_image "$CMAKE_ARMHF_ARGS -DSDL2IMAGE_VENDORED=ON"
#build_3rdparty_cmake_sysroot SDL_mixer "$CMAKE_ARMHF_ARGS -DSDL2MIXER_VENDORED=ON"

# Build included components
# 32bit
build_3rdparty_cmake_sysroot gl4es "-DGLVND=OFF -DHYBRIS=ON -DNOX11=OFF -DNOEGL=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMULTIARCH_PREFIX=arm-linux-gnueabihf $CMAKE_ARMHF_ARGS"
build_3rdparty_cmake_sysroot box86 "-DARM64=ON -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo $CMAKE_ARMHF_ARGS"

# Use shipped linker with box86 directly as well
patchelf --set-interpreter /opt/click.ubuntu.com/box64andwine.fredldotme/current/sysroot/armhf/lib/ld-linux-armhf.so.3 $INSTALL/bin/box86

# glvnd-compatible naming
# mv $INSTALL/usr/lib/arm-linux-gnueabihf/gl4es/libGL.so.1 $INSTALL/usr/lib/arm-linux-gnueabihf/gl4es/libGLX_gl4es.so.0

# Remove unnecessary cruft after compilation
rm -rf $INSTALL/sysroot/armhf/usr/{bin,sbin,games,share,include}
rm -rf $INSTALL/sysroot/armhf/{bin,sbin,home,tmp,proc,sys,dev,etc,debootstrap,root,run,var,mnt}
rm -rf $INSTALL/sysroot/armhf/{firmware,vendor,product,factory,system,persist,data,metadata,odm,cache,apex}
rm -rf $INSTALL/sysroot/armhf/usr/lib/systemd
rm -rf $INSTALL/sysroot/armhf/usr/lib/python*
rm -rf $INSTALL/sysroot/armhf/usr/lib/ssl
rm -rf $INSTALL/sysroot/armhf/usr/lib/environment.d

# Box64 running scripts for us only needs bins and libs
rm -rf $INSTALL/sysroot/amd64/usr/{share,include}
rm -rf $INSTALL/sysroot/amd64/{bin,sbin,home,tmp,proc,sys,dev,etc,debootstrap,root,run,var,mnt}
ln -sf usr/bin $INSTALL/sysroot/amd64/bin
ln -sf usr/sbin $INSTALL/sysroot/amd64/sbin
rm -rf $INSTALL/sysroot/amd64/usr/lib/systemd
rm -rf $INSTALL/sysroot/amd64/usr/lib/python*
rm -rf $INSTALL/sysroot/amd64/usr/lib/ssl
rm -rf $INSTALL/sysroot/amd64/usr/lib/environment.d

# Clean up amd64 sysroot bins from symlinks
for f in $(ls $INSTALL/sysroot/amd64/usr/{bin,sbin}/*); do
    if [ -L $f ]; then
        rm $f
    fi
done

if [ -d $INSTALL/wine ]; then
    rm -rf $INSTALL/wine
fi
mkdir -p $INSTALL/wine
wget -O $BUILD_DIR/wine.tar.xz https://github.com/Kron4ek/Wine-Builds/releases/download/8.4/wine-8.4-staging-amd64.tar.xz
tar xvf $BUILD_DIR/wine.tar.xz -C $INSTALL/wine --strip-components=1

exit 0
