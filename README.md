# How to develop and test with Kubernetes
This solution enables us to run PoUW in a Kubernetes cluster. The instructions are for Mac OS X, however except installation of prerequisites, everything else is similar.

## Install prerequisites:
You must create the folder `ssh-keys` under the root folder and put a copy of your `id_rsa` file in it. 

```
brew install bash-completion
brew cask install docker
brew install kubectl
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 \
  && chmod +x minikube
sudo mv minikube /usr/local/bin
```

## Build the PoUW images

We need the basic PoUW images. This has to be done on your development machine (not inside Minikube) for performance reasons.

First, we'll build the blockchain image:
```
./build-image.sh --role=blockchain --version=dev
```

Then, we will build the consensus (Python code) image:
```
./build-image.sh --role=consensus --version=dev --passphrase=<your_ssh_password>
```

## Start the Minikube cluster

Start the local Kubernetes cluster (please note that the `--vm-driver` option is optional):
```
minikube start --memory 4096 --cpus=2 --vm-driver=parallels
```

We need the Docker internal to MiniKube. You need to run this command to be able to fetch images from the local disk later:
```
eval $(minikube docker-env)
```

## Copy the PoUW images inside Minikube

In a fresh terminal, we will save the PoUW images using the local installation of Docker:
```
docker save pouw-blockchain:dev > img_blockchain
docker save pouw-consensus:dev > img_consensus
```

In the terminal with Minikube run these commands:
```
docker load < img_blockchain
docker load < img_consensus
```

You can see all images loaded into the Minikube local Docker by issuing the folowing command:
```
docker image ls
```

## Configure settings

We will create a ConfigMap holding some environment variables. To do so, we'll run this command:
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
ssh -i ~/.minikube/machines/minikube/id_rsa docker@$(minikube ip)
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
For this operation you need 3 terminals open, and in each you should previously have run the command:
```
eval $(minikube docker-env)
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
sh run-client.sh
````

And you can view the progress of training using on miner 1, for example:
````
kubectl logs pouw-miner-1 -c pouw-miner
kubectl logs pouw-miner-1 -c pouw-miner-verifier
kubectl logs pouw-miner-1 -c pouw-miner-blockchain
````

The training progress can also be monitored from the Minikube dashboard.