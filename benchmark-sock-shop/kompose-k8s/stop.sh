#!/bin/bash
set -e

attempt=${1:-1}
[ $attempt -ne "0"  ] && [ "$((attempt%10))" -eq "0" ] && csmail send -s "$attempt attempts to stop the cluster" "$attempt attempts to stop the cluster so far, on swarm-master... " "thomashareau@free.fr"


>&2 echo "$attempt attempts to stop cluster"


docker stack rm sock-shop 2> /dev/null

retries=0
stopped=false
while ! $stopped && [ "$retries" -le "5" ]; do
	docker stack services sock-shop --format "{{.Replicas}}" 2>/dev/null | grep 0/ > /dev/null  && stopped=false || stopped=true
	docker network ls 2>/dev/null | grep sock-shop > /dev/null && stopped=false || stopped=true 
	$stopped || ((++retries))
done

echo "$stopped:$retries"

$stopped || ./stop.sh $((attempt +1))
