FROM debian:jessie
MAINTAINER Toni Michel <TM@TONIMICHEL.DE>
ENV REFRESHED_AT 2016-06-08
ENV DEBIAN_FRONTEND noninteractive

ENV LATEST_AFL_PACKAGE http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz

# Base
RUN \
    echo "deb http://ftp.de.debian.org/debian/ jessie main contrib non-free" > /etc/apt/sources.list \
    && echo "deb-src http://ftp.de.debian.org/debian/ jessie main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list \
    && apt-get update \
        --quiet \
    && apt-get install \
        --yes \
        --no-install-recommends \
        --no-install-suggests \
    libgtk2.0-dev \
    libgtk-3-dev \
    autoconf \
    automake \
    gcc \
    libtool \
    make \
    nasm \
    subversion \
    git \
    wget \
    apt-utils



# Get ready to build.
WORKDIR /tmp

# Get and build AFL.
RUN \
    wget \
    $LATEST_AFL_PACKAGE \
        --no-verbose \
    && mkdir afl-src \
    && tar -xzf afl-latest.tgz \
        -C \
        afl-src \
        --strip-components=1 \
    && cd afl-src \
    && grep ASAN | env \
    && unset ASAN_OPTIONS \
    && export ASAN_OPTIONS \
    && sed -i 's/^\/\/ #define USE_64BIT/#define USE_64BIT/gI' config.h \
    && make \
    && make install \
    && rm -rf \
        /tmp/afl-latest.tgz \
        /tmp/afl-src



# Get evince dependencies for evince.
RUN \
   mkdir /BUILD \
   && cd /BUILD/ \
   && apt-get build-dep \
        --yes \
        --no-install-recommends \
        --no-install-suggests evince

# Get evince (3.14.1) and prepare everything so we can fuzz along
RUN \
   cd /BUILD/ \
   && ln -s /usr/bin/gtk-update-icon-cache-3.0 /usr/bin/gtk-update-icon-cache \
   && git clone git://git.gnome.org/evince \
   && cd /BUILD/evince \
   && git checkout tags/3.14.1
   && autoreconf -fiv \
   && AFL_HARDEN=1 \
      CC=/usr/local/bin/afl-gcc \
      CXX=/usr/local/bin/afl-g++ ./configure --disable-shared \
   && make -j 4\
   && make install

# Clean up packages.
RUN \
  apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /BUILD/


VOLUME ["/data"]
WORKDIR /data
CMD ["bash"]
