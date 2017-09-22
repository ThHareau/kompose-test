#!/bin/bash
set -e

attempt=${1:-1}
[ $attempt -ne "0"  ] && [ "$((attempt%10))" -eq "0" ] && csmail send -s "$attempt attempts to stop the cluster" "$attempt attempts to stop the cluster so far, on swarm-master... " "thomashareau@free.fr"


>&2 echo "$attempt attempts to stop cluster"


kubectl delete --cascade --ignore-not-found --now namespace sock-shop;

retries=0
deleted=false
while  ! $deleted  && [ $retries -lt 5 ]; do 
	[ "$retries" -eq "0" ] || sleep 30
	kubectl get namespace sock-shop > /dev/null 2>&1 && ((++retries)) || deleted=true
	$deleted || >&2 echo "$retries: $pods"
done


$deleted || ./stop.sh $((attempt +1))
