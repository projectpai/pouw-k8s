FROM ubuntu:16.04

ARG WORKER_BRANCH=master

RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y ssh git g++ cmake python3-pip python3.7-dev python3.7 python3-setuptools && \
    git clone https://github.com/projectpai/pouw-main-iteration --branch ${WORKER_BRANCH} /opt/main-iteration

RUN cd /opt/main-iteration && \
    python3.7 -m pip install --upgrade pip && \
    sed -i '1s/boto3//;' requirements.txt && \
    python3.7 -m pip install -r requirements.txt && \
    python3.7 -m pip install -U setuptools && \
    python3.7 setup.py develop && \
    mkdir /app && \
    rm -rf /root/.ssh

WORKDIR /app

CMD [ "/bin/bash", "-c", "python3.7 /opt/main-iteration/pai/pouw/verification/server.py --redis-host $REDIS_HOST --redis-port $REDIS_PORT" ]