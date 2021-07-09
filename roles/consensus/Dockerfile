FROM ubuntu:20.04

ARG WORKER_BRANCH=master

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update && apt-get install -y git g++ cmake python3-pip python3-dev python3 python3-setuptools && \
    git clone https://github.com/projectpai/pouw-main-iteration --branch ${WORKER_BRANCH} /opt/main-iteration

RUN cd /opt/main-iteration && \
    sed -i '1s/boto3//;' requirements.txt && \
    pip install -r requirements.txt && \
    python3 setup.py develop && \
    mkdir /app

WORKDIR /app

CMD [ "/bin/bash", "-c", "python3 /opt/main-iteration/pai/pouw/verification/server.py --redis-host $REDIS_HOST --redis-port $REDIS_PORT" ]