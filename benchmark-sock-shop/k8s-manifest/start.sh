#!/bin/bash
set -e

attempt=${1:-1}
[ $attempt -ne "0"  ] && [ "$((attempt%10))" -eq "0" ] && csmail send -s "$attempt attempts to start the cluster" "$attempt attempts to start the cluster so far, on real-k8s-master... " "thomashareau@free.fr"


>&2 echo "$attempt attempts to start the  cluster"


kubectl create namespace sock-shop
kubectl create -f complete-demo.yaml 
while IFS='' read -r dep || [[ -n "$dep" ]]; do
	kubectl rollout status -n sock-shop $dep 1>&2;
done <<< `kubectl get deploy -n sock-shop -o 'name' `


sleep 10
curl -f -s -o /dev/null -w "%{http_code}" -H "Authorization: Basic dXNlcjpwYXNzd29yZA==" `./get_ip.sh`/login &&
		curl -f -s -w "%{http_code}" -o /dev/null `./get_ip.sh `/catalogue ||
		       		./restart.sh $((attempt + 1))
