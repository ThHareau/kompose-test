# Kompose test

This repository can be used to compare the performances of a project generated with compose and the original resources. 

Two repositories are provided: example voting app and sock shop

These scripts do not take install any cluster, it has to be done before. Several cluster must be provided: a k8s cluster to test the kompose version, a swarm cluster to test original compose file. They are supposed to exist on the same time, however the file exec.sh is very easy to modify if only one cluster have to be benchmarked. 

The tests are quite long, (20 minutes for example voting app, several hours for sockshop). Using them with nohup on a external machine is probably a good idea. 

Since the tests for sock shop are very long, it is possible to combine it with [csmail](https://github.com/thhareau/csmail). In this case, an email will be sent each time a test is finished. 
