#!/bin/bash -x

python3.7 /opt/main-iteration/pai/pouw/nodes/decentralized/client.py --redis-host $REDIS_HOST --redis-port $REDIS_PORT --client-task-definition-path task-definition.yaml --use-continuous-training 
