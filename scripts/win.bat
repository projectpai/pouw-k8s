docker build --no-cache --build-arg PAICOIN_BRANCH="pouw-q4" --build-arg WORKER_BRANCH="master" --build-arg CONTAINER_VERSION="1.0" --build-arg GIT_REPO="github.com" --tag "blockchain:dev" -f "roles/blockchain/Dockerfile" .
docker build --no-cache --build-arg PAICOIN_BRANCH="pouw-q4" --build-arg WORKER_BRANCH="master" --build-arg CONTAINER_VERSION="1.0" --build-arg GIT_REPO="github.com" --tag "consensus:dev" -f "roles/consensus/Dockerfile" .