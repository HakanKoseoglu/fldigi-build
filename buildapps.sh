#!/bin/bash
mkdir -p /wsjtx-src/hamlib-prefix /hamlib/

cd /wsjtx-src/hamlib-prefix

## Build chain
apt-get install -y \
autoconf \
automake \
asciidoc \
cmake \
build-essential \
libtool \
gfortran \
git \
libqt5serialport5-dev \
libboost-log-dev \
libqt5quick5 \
libqt5multimedia5-plugins \
libusb-1.0-0-dev \
libudev-dev \
libfftw3-dev \
qttools5-dev \
qtmultimedia5-dev \
qtbase5-dev \
qtdeclarative5-dev \
texinfo \
libportaudio2 \
portaudio19-dev \
wget \
&& apt-get clean 
