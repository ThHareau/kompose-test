#!/bin/bash
set -e

attempt=${1:-0}
[ $attempt -ne "0"  ] && [ "$((attempt%10))" -eq "0" ] && csmail send -s "$attempt to stop server so far" "$attempt th attempt to stop server on k8s-master..." "thomashareau@free.fr"

>&2 echo "Attempt $attempt to stop cluster"


kubectl delete --cascade --ignore-not-found --now -f kompose-manifest 1>&2

retries=0
deleted=false
while  ! $deleted  && [ $retries -lt 5 ]; do 
	[ "$retries" -eq "0" ] || sleep 30
	[ "`kubectl get all | wc -l`" -le "2" ] && deleted=true || ((++retries))
	$deleted || >&2 echo "$retries: `kubectl get all -o name | tr '\n' ' '`"
done

$deleted || ./stop.sh $((attempt + 1))
