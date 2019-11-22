# How to run tests for k8s

1. Block commitment:
````
kubectl create -f tests/block-commitment.yaml
````

We prepared a test pod that commits to blocks at a distance of 4 iterations vs the default of 5. You should be able to see that the other miners reject blocks produced by the test pod.