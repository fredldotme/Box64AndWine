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
            -DCMAKE_CXX_FLAGS="-isystem $INSTALL/include -L$INSTALL/lib -Wno-deprecated-declarations -Wl,-rpath-link,$INSTALL/lib" \
            -DCMAKE_C_FLAGS="-isystem $INSTALL/include -L$INSTALL/lib -Wno-deprecated-declarations -Wl,-rpath-link,$INSTALL/lib" \
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
CMAKE_ARMHF_ARGS="-DCMAKE_C_COMPILER=/usr/bin/arm-linux-gnueabihf-gcc -DCMAKE_CXX_COMPILER=/usr/bin/arm-linux-gnueabihf-g++ -DCMAKE_AR=/usr/bin/arm-linux-gnueabihf-ar -DCMAKE_LINKER=/usr/bin/arm-linux-gnueabihf-ld -DCMAKE_SYSROOT=$INSTALL/sysroot/armhf"

# Fetch & create armhf sysroot
if [ -d $BUILD_DIR/sysroot/armhf ]; then
    rm -rf $BUILD_DIR/sysroot/armhf
fi
mkdir -p $BUILD_DIR/sysroot/armhf

if [ -d $INSTALL/sysroot/armhf ]; then
    rm -rf $INSTALL/sysroot/armhf
fi
mkdir -p $INSTALL/sysroot/armhf

fakeroot fakechroot debootstrap \
    --arch armhf \
    --components=main,restricted,universe \
    --include=libgtk-3-0,libx11-dev \
    --variant=fakechroot \
    --foreign \
    focal \
    $INSTALL/sysroot/armhf

# Build main sources
build_project
build_wrappers x86_64
build_wrappers i386 "$CMAKE_ARMHF_ARGS"

# Build included components
# 32bit
build_3rdparty_cmake gl4es "-DNO_GBM=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMULTIARCH_PREFIX=arm-linux-gnueabihf $CMAKE_ARMHF_ARGS"
build_3rdparty_cmake_sysroot box86 "-DARM64=ON -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo $CMAKE_ARMHF_ARGS"

# Use shipped linker with box86 directly as well
patchelf --set-interpreter /opt/click.ubuntu.com/box64andwine.fredldotme/current/sysroot/armhf/lib/ld-linux-armhf.so.3 $INSTALL/bin/box86

# 64bit
build_3rdparty_cmake gl4es "-DNO_GBM=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMULTIARCH_PREFIX=aarch64-linux-gnu"
build_3rdparty_cmake box64 "-DGENERIC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo"

# Remove unnecessary cruft
rm -rf $INSTALL/sysroot/armhf/usr/{bin,sbin,games,share,include}
rm -rf $INSTALL/sysroot/armhf/{bin,sbin,home,tmp,proc,sys,dev,etc,debootstrap,root,run,var}

if [ -d $INSTALL/wine ]; then
    rm -rf $INSTALL/wine
fi
mkdir -p $INSTALL/wine
wget -O $BUILD_DIR/wine.tar.xz https://github.com/Kron4ek/Wine-Builds/releases/download/8.0/wine-8.0-amd64.tar.xz
tar xvf $BUILD_DIR/wine.tar.xz -C $INSTALL/wine --strip-components=1

exit 0
