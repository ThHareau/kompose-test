#!/bin/bash
set -e

attempt=${1:-1}
[ $attempt -ne "0"  ] && [ "$((attempt%10))" -eq "0" ] && csmail send -s "$attempt attempts to stop the cluster" "$attempt attempts to stop the cluster so far, on swarm-master... " "thomashareau@free.fr"


>&2 echo "$attempt attempts to stop cluster"


docker stack rm sock-shop 2> /dev/null

retries=0
stopped=false
while ! $stopped && [ "$retries" -le "5" ]; do
	[ "$retries" -gt "0" ] && sleep 10
	docker stack services sock-shop --format "{{.Replicas}}" 2>/dev/null | grep -v "0/" > /dev/null  && services_stoped=false || services_stoped=true
	docker network ls 2>/dev/null | grep sock-shop > /dev/null && network_stopped=false || network_stopped=true 
	$services_stoped && $network_stopped && stopped=true || ((++retries))
done

$stopped || ./stop.sh $((attempt +1))
