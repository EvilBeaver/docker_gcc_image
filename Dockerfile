FROM ubuntu:16.04

RUN apt-get update \
    && apt-get -y install software-properties-common git build-essential uuid-dev curl wget

RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt update \
    && apt -y install gcc-6 g++-6-multilib gcc-6-multilib \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 50 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 70

RUN curl -sSL https://cmake.org/files/v3.5/cmake-3.5.2-Linux-x86_64.tar.gz | tar -xzC /opt
ENV PATH "$PATH:/opt/cmake-3.5.2-Linux-x86_64/bin"

ARG boost_ver_major="1"
ARG boost_ver_minor="56"
ARG boost_ver_file=${boost_ver_major}_${boost_ver_minor}

RUN wget -O boost_${boost_ver_file}_0.tar.gz "http://sourceforge.net/projects/boost/files/boost/${boost_ver_major}.${boost_ver_minor}.0/boost_${boost_ver_file}_0.tar.gz/download" \
 && tar xzvf "boost_${boost_ver_file}_0.tar.gz"

WORKDIR boost_${boost_ver_file}_0

#x86
RUN ./bootstrap.sh --prefix=/usr/local --libdir=/usr/local/lib32 --with-libraries=system,chrono,locale  && \
    ./b2 --toolset=gcc variant=release cxxflags=-fPIC link=static architecture=x86 address-model=32 install
#x64
RUN ./bootstrap.sh --prefix=/usr/local --libdir=/usr/local/lib64 --with-libraries=system,chrono,locale && \
    ./b2 --toolset=gcc variant=release cxxflags=-fPIC link=static architecture=x86 address-model=64 install

WORKDIR /var/build
RUN rm -rf boost_${boost_ver_file}_0

ENV BOOST_ROOT=/usr/local
