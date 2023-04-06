# BASE: https://github.com/ryankurte/docker-ns3
FROM debian:11
MAINTAINER ondrejko
LABEL Description="isolated environment so ns3 does not break"

RUN apt update

RUN apt install -y apt-utils

# General dependencies
RUN apt-get install -y \
  git \
  mercurial \
  wget \
  vim \
  tar \
  autoconf \
  bzr \
  cvs \
  unrar-free \
  build-essential \
  clang \
  valgrind \
  gsl-bin \
  libgslcblas0 \
  libgsl-dev \
  flex \
  bison \
  libfl-dev \
  tcpdump \
  sqlite3 \
  libsqlite3-dev \
  libxml2 \
  libxml2-dev \
  vtun \
  lxc \
  libboost-dev \
  qtbase5-dev \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  cmake \
  libc6-dev \
  libc6-dev-i386 \
  g++-multilib \
  software-properties-common 

# Install TZ-data
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata

# Install pip shit
RUN python3 -m pip install --upgrade pip 

# Get correct pip shit version
COPY ./binding-reqs.txt .
RUN pip install -r binding-reqs.txt

# Create working directory
WORKDIR /usr

# Download NS3
RUN wget https://www.nsnam.org/releases/ns-allinone-3.38.tar.bz2
RUN tar -xf ./ns-allinone-3.38.tar.bz2

# Get openflow
RUN cd /usr && hg clone http://code.nsnam.org/openflow

# Build openflow
RUN cd /usr/openflow && ./waf configure && ./waf build

# Replace with modified CMakeLists
COPY CMakeLists.txt /usr/ns-allinone-3.38/ns-3.38/CMakeLists.txt

# Configure ns3
RUN cd /usr/ns-allinone-3.38/ns-3.38/ && ./ns3 configure --enable-python-bindings --with-openflow=/usr/openflow/

# Build ns3
RUN cd /usr/ns-allinone-3.38/ns-3.38/ && ./ns3 build

# Install SUMO
RUN apt-get install -y sumo sumo-tools

# Copy openflow libraries
RUN cp -r /usr/openflow/include/openflow /usr/ns-allinone-3.38/ns-3.38/build/include

# Copy vanetlab pip requirements
COPY ./vanetlab-be/requirements.txt /usr/requirements.txt
RUN cd /usr && pip install -r requirements.txt

# Open port for flask app
EXPOSE 5000

# just chilld now. idk.
