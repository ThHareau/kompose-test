# Kompose test

This repository can be used to compare the performances of a project generated with compose and the original resources. 

Two repositories are provided: example voting app and sock shop

These scripts does not take care of installing the cluster, it has to be done before. Several cluster must be provided: a k8s cluster to test the kompose version, a swarm cluster to test original compose file. They are suppose to exist on the same time, however the file exec.sh is very easy to modify if only one cluster has to be benchmarked. 


