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

function wait_catalogue {
	retry=0
	failure=true
	while $failure && [ "$retry" -lt "5" ]; do
		res=$(curl -f -s `./get_ip.sh`/catalogue) &&
			grep -q "error" <<< "$res" && 
			failure=false || failure=true
		$failure && 
			>&2 echo "Waiting for DB to start" && 
			sleep 15 && 
			((++retry))

	done	
	$failure && return 1 || true
}

sleep 10
curl -f -s -o /dev/null -w "%{http_code}" -H "Authorization: Basic dXNlcjpwYXNzd29yZA==" `./get_ip.sh`/login &&
		wait_catalogue ||
		       		./restart.sh $((attempt + 1))
