#!/bin/bash
set -e

attempt=${1:-0}
[ $attempt -ne "0"  ] && [ "$((attempt%10))" -eq "0" ] && csmail send -s "$attempt attempts to stop the server" "$attempt th attempt to start the server on k8s-master" "thomashareau@free.fr"


>&2 echo "Starting cluster"

kubectl create -f kompose-manifest 1>&2

deploys=`kubectl get deploy -o name`
for deploy in $deploys; do
	kubectl rollout status $deploy 1>&2
done

sleep 10
curl -f -s -o /dev/null -w "%{http_code}" -H "Authorization: Basic dXNlcjpwYXNzd29yZA==" `./get_ip.sh`/login &&
	curl -f -s -w "%{http_code}" -o /dev/null `./get_ip.sh `/catalogue || 
		./restart.sh $attempt
