#!/usr/bin/env bash

GIT_REPO=github.com
WORKER_BRANCH="master"
PAICOIN_BRANCH="pouw-q4"

for i in "$@"
do
case $i in
    -r=*|--role=*)
    ROLE="${i#*=}"
    shift
    ;;
    -p=*|--passphrase=*)
    SSH_PASS="${i#*=}"
    shift
    ;;
    -b=*|--branch=*)
    WORKER_BRANCH="${i#*=}"
    PAICOIN_BRANCH="${i#*=}"
    shift
    ;;
    -g=*|--gitrepo=*)
    GIT_REPO="${i#*=}"
    shift
    ;;
    -v=*|--version=*)
    VERSION="${i#*=}"
    shift
    ;;
    *)

    ;;
esac
done

if ! [[ "$ROLE" =~ ^(blockchain|consensus)$ ]]; then
    echo "Role can only be: blockchain or consensus."
    exit
fi

echo "ROLE        = ${ROLE:?No role. Please specify it using this option: --role=<role>, where role can be blockchain or consensus.}"
echo "VERSION     = ${VERSION:?No version tag. Please specify it using this option: --version=<username>}"

TAG="pouw-$ROLE:$VERSION"
echo "TAG         = $TAG"
DOCKER_FILE="roles/$ROLE/Dockerfile"
echo "DOCKER_FILE = $DOCKER_FILE"
echo "SSH_PASS    = $SSH_PASS"
echo "GIT_REPO    = $GIT_REPO"
echo "Py BRANCH   = $WORKER_BRANCH"
echo "PAI BRANCH  = $PAICOIN_BRANCH"

docker build --no-cache --build-arg PAICOIN_BRANCH=$PAICOIN_BRANCH --build-arg WORKER_BRANCH=$WORKER_BRANCH --build-arg SSH_KEY_PASSPHRASE=$SSH_PASS --build-arg CONTAINER_VERSION=$VERSION --build-arg GIT_REPO=$GIT_REPO --tag $TAG -f $DOCKER_FILE .
