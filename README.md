# How to develop and test with Kubernetes
This solution enables us to run PoUW in a Kubernetes cluster.

## Prerequisites:
* Minikube

## Build the PoUW images

We need the PoUW images for the blockchain and for the modified consensus part. This has to be done on your development machine (not inside Minikube) for performance reasons.

### On MacOS/Linux
```
./build-image.sh --role=blockchain --version=dev
./build-image.sh --role=consensus --version=dev
```

### On Windows
```
docker build --no-cache --build-arg PAICOIN_BRANCH="pouw-q4" --build-arg WORKER_BRANCH="master" --build-arg CONTAINER_VERSION="1.0" --build-arg GIT_REPO="github.com" --tag "pouw-blockchain:dev" -f "roles/blockchain/Dockerfile" .
docker build --no-cache --build-arg PAICOIN_BRANCH="pouw-q4" --build-arg WORKER_BRANCH="master" --build-arg CONTAINER_VERSION="1.0" --build-arg GIT_REPO="github.com" --tag "pouw-consensus:dev" -f "roles/consensus/Dockerfile" .
```

## Start the Minikube cluster

```
minikube start --memory 8192 --cpus=2
```

We need the Docker from the MiniKube. You need to run this command to be able to transfer images from the local disk:

On MacOS/Linux:
```
eval $(minikube docker-env)
```


On Windows Powershell:
```
minikube docker-env
& minikube -p minikube docker-env | Invoke-Expression
```

## Copy the PoUW images inside Minikube

In another terminal, we will save the PoUW images using the local installation of Docker:
```
docker save pouw-blockchain:dev > img_blockchain
docker save pouw-consensus:dev > img_consensus
```

In the previous terminal with Minikube run these commands (both terminals should be in the same folder to be able to refer to saved images):
```
docker load --input img_blockchain
docker load --input img_consensus
```

You can see all images loaded into the Minikube local Docker by issuing the folowing command:
```
docker image ls
```

## Configure settings

Inside Minikube, we will create a ConfigMap holding some environment variables. To do so, we'll run this command:
```
kubectl create configmap settings-map --from-env-file=env.list
```

We have `conf/redis.conf` for Redis settings. We have to run:
````
kubectl create configmap redis-config-map --from-file=config/redis.conf
````

For paicoin settings we must run this command to register them in the Minikube:
````
kubectl create configmap paicoin-config-map --from-file=config/chainparams.conf --from-file=config/paicoin.conf
````

All the settings files are in the `config` folder.

## Creating storage for holding temporary data
We need a persistent volume to hold temporary data that is shared among all pods. The total size cannot exceed 1 Mb now.

First SSH into the Minikube node:
```
minikube ssh
```

And create the folders `pouw-data`:
```
sudo mkdir /mnt/pouw-data
sudo mkdir /mnt/pouw-bucket
```

Log out from the Minikube node, and then create the associated storage from the `kubectl` utility:

```
kubectl create -f storage.yaml
```

In this version, each node has a share on `/usr/share/pouw-data`. The file `nodes` contains a list with all alive nodes (IP, name and role).
## Add the script to launch a task from the client node

Run this command in terminal:
````
kubectl create configmap run-client-map --from-file=scripts/run-client.sh --from-file=config/task-definition.yaml
````

## Deploying the PoUW images to the Minikube cluster
For this operation you need 3 terminals open, and in each you should previously have run the command on MacOS/Linux:
```
eval $(minikube docker-env)
```

On Windows Powershell:
```
minikube docker-env
& minikube -p minikube docker-env | Invoke-Expression
```

1. The first terminal is used for monitoring the PoUW cluster. Here you should run this command:
```
kubectl get pods -w -l app=pouw
```

2. In the second, terminal we deploy the PoUW nodes:
```
kubectl create -f cluster.yaml
```

Note: To delete the deployment (not the cluster), you should run:
```
kubectl delete -f cluster.yaml
```

3. In the third terminal, we run the Minikube dashboard:
```
minikube dashboard
```

This command will open a web UI application to manage the cluster and view each pod's activity.

## Start ML training

You must login into `pouw-client-0` using this command:
````
kubectl exec -it pouw-client-0 -c pouw-client -- /bin/bash
````

Then you can start the training using the provided client script:
````
python3 /opt/main-iteration/pai/pouw/nodes/decentralized/client.py --redis-host $REDIS_HOST --redis-port $REDIS_PORT --client-task-definition-path task-definition.yaml --use-continuous-training
````

And you can view the progress of training using on miner 1, for example:
````
kubectl logs pouw-miner-1 -c pouw-miner
kubectl logs pouw-miner-1 -c pouw-miner-verifier
kubectl logs pouw-miner-1 -c pouw-miner-blockchain
````

The training progress can also be monitored from the Minikube dashboard.
