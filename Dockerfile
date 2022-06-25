ARG VERSION=latest
#FLDigi Build Script

FROM debian:sid-slim as base
MAINTAINER m0khr.uk+docker@gmail.com
ENV DEBIAN_FRONTEND=noninteractive
RUN export DEBIAN_FRONTEND=noninteractive && ln -fs /usr/share/zoneinfo/posix/UTC /etc/localtime
ENV TZ=Europe/London
ENV LANG en_US.UTF-8
RUN /bin/sh -c echo $TZ > /etc/timezone && apt-get update && apt-get upgrade -y && apt-get install -y tzdata locales && rm /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata && date >> ~/buildtime
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    update-locale LANG=en_GB.UTF-8

FROM base as builder
MAINTAINER m0khr.uk+docker@gmail.com
ENV DEBIAN_FRONTEND=noninteractive
RUN export DEBIAN_FRONTEND=noninteractive && ln -fs /usr/share/zoneinfo/posix/UTC /etc/localtime && mkdir /wsjtx-src/
ENV TZ=Europe/London

#libhamlib-dev \
#libhamlib4 \

RUN apt-get install -y \
autoconf \
automake \
build-essential \
libtool \
libboost-log-dev \
libusb-1.0-0-dev \
libudev-dev \
libfftw3-dev \
libportaudio2 \
portaudio19-dev \
libfltk1.3-dev \
libpng-dev \
libsamplerate0-dev \
libsndfile1-dev \
libxft-dev \
libpulse-dev \
libjpeg-dev \
libxext-dev \
libxfixes-dev \
libxinerama-dev \
libxcursor-dev \
git \
wget \
&& apt-get clean
ARG rerun-incrementer-1
COPY do_build.sh /opt/scripts/
RUN /bin/bash /opt/scripts/do_build.sh


##Build runtime
FROM base as runtime
MAINTAINER m0khr.uk+docker@gmail.com
ENV DEBIAN_FRONTEND=noninteractive
RUN export DEBIAN_FRONTEND=noninteractive && ln -fs /usr/share/zoneinfo/posix/UTC /etc/localtime
ENV TZ=Europe/London
RUN /bin/sh -c echo $TZ > /etc/timezone \
&& cat ~/buildtime \
&& mkdir -p /run/systemd \
&& echo 'docker' > /run/systemd/container \
&& apt-get update \
&& apt-get upgrade
RUN apt-get install -y \
    hicolor-icon-theme \
    libqt5multimedia5-plugins \
    libcanberra-gtk* \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
	libpulse0 \
	libv4l-0 \
	libfftw3-3 \
	libqt5printsupport5 \
	libqt5multimedia5 \
	libqt5sql5 \
	libqt5serialport5 \
	locales \
	libboost-log1.74.0 \
	libusb-1.0-0 \
	libpulse0 \
	libfltk1.3 \
    libudev-dev \
    libpng-tools \
	fonts-symbola \
	alsa-utils \
	pulseaudio \
    libportaudio2 \
&& mkdir /fldigi
ENV LC_ALL=C
WORKDIR /
COPY --from=builder /fldigi /fldigi
COPY fldigi.sh /fldigi/fldigi.sh
CMD ["/fldigi/fldigi.sh"]
