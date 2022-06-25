#!/bin/bash

BASE_URL="http://www.w1hkj.com/files"

SOURCE_DIR="/opt/source"
mkdir -p $SOURCE_DIR /fldigi

function get_version() {
    wget "${BASE_URL}/$1/readme.txt"
    version=$(grep -E -o [0-9]+\\.[0-9]+\\.[0-9]+ readme.txt | head -1)
    rm readme.txt
    echo $version;
    
}

function get_latest_archive() {
    vers=$(get_version $1)
    wget -nc "${BASE_URL}/$1/${1}-$vers.tar.gz"
    tar xvf "${1}-$vers.tar.gz" > /dev/null
    echo "${1}-$vers"
}


function do_build() {
    folder=$(get_latest_archive $1)
    cd $folder
    CPPFLAGS="-I/usr/include/libusb-1.0"
    LDFLAGS="-L/usr/lib/x86_64-linux-gnu"
    ./configure --prefix=/fldigi --enable-static --enable-optimizations=native
    make -j $(nproc)
    make install
}

function build_forked_hamlib() {
    ### Build Hamlib for WSJTX

    cd $SOURCE_DIR
    mkdir -p hamlib-build

    cd hamlib-build
    git clone git://git.code.sf.net/u/bsomervi/hamlib src

    cd src
    git checkout integration

    ./bootstrap
    mkdir ../build

    cd ../build
    ../src/configure --prefix=/usr/local \
    --disable-shared --enable-static \
    --without-cxx-binding --disable-winradio \
    --without-libusb    \
    CFLAGS="-g -O2 -fdata-sections -ffunction-sections" \
    LDFLAGS="-Wl,--gc-sections"
    make
    make install-strip

}
function build_hamlib(){
    cd $SOURCE_DIR
    mkdir -p hamlib-build

    cd hamlib-build
    git clone https://github.com/Hamlib/Hamlib.git src

    cd src
    git checkout integration

    ./bootstrap
    mkdir -p ../build
    cd ../build
    ../src/configure --prefix=/usr/local \
    --disable-shared --enable-static \
    --without-cxx-binding --disable-winradio \
    --without-libusb    \
    CFLAGS="-g -O2 -fdata-sections -ffunction-sections" \
    LDFLAGS="-Wl,--gc-sections"
    make
    make install-strip
}

cd "$SOURCE_DIR"
#build_hamlib
#build_forked_hamlib

cd "$SOURCE_DIR"
do_build "fldigi"
cd "$SOURCE_DIR"
do_build "flrig"
cd "$SOURCE_DIR"
do_build "flmsg"
cd "$SOURCE_DIR"
do_build "flamp"
cd "$SOURCE_DIR"
do_build "flmsg"

echo "Done!!"
