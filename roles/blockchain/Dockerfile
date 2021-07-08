FROM ubuntu:20.04
ARG PAICOIN_BRANCH="pouw-q4"

RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:rock-core/qt4 -y && \
    apt-get update && \
    apt-get install -y \
    python3 \
    cpp \
    build-essential \
    gcc \
    g++ \
    make \
    pkg-config \
    autoconf \
    libboost-all-dev \
    libssl-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libqt4-dev \
    libqrencode-dev \
    libtool \
    bsdmainutils \
    libevent-dev \
    curl \
    ssh \
    git

RUN  git clone -b ${PAICOIN_BRANCH} --single-branch https://github.com/projectpai/paicoin.git /opt/paicoin && cd /opt/paicoin && git checkout ${PAICOIN_BRANCH}

ADD scripts/berkley.sh /opt/paicoin/berkley.sh

RUN cd /tmp && \
    git clone -b v1.30.2 --single-branch https://github.com/grpc/grpc && \
    cd grpc && \
    git submodule update --init && \
    CXXFLAGS='-Wno-error' make -j $(lscpu | grep -E '^CPU\(s)' | awk '{print $2}') HAS_SYSTEM_PROTOBUF=false && \
    make -j $(lscpu | grep -E '^CPU\(s)' | awk '{print $2}') install && \
    cd third_party/protobuf && \
    make -j $(lscpu | grep -E '^CPU\(s)' | awk '{print $2}') install && \
    rm -rf /tmp/grpc
    
ENV LD_LIBRARY_PATH /usr/local/lib

WORKDIR /opt/paicoin

RUN /bin/bash berkley.sh && \
    mkdir /app && \
    ln -s /opt/paicoin/src/paicoind /app/paicoind && \
    ln -s /opt/paicoin/src/paicoin-cli /app/paicoin-cli

WORKDIR /app

CMD ["/bin/bash", "-c", "paicoind -mine-genesis-block && paicoind -ignore-not-connected"]