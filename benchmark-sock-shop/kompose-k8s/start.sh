#!/bin/bash
set -e

attempt=${1:-1}
[ $attempt -ne "0"  ] && [ "$((attempt%10))" -eq "0" ] && csmail send -s "$attempt attempts to start the cluster" "$attempt attempts to start the cluster so far, on swarm-master... " "thomashareau@free.fr"


>&2 echo "$attempt attempts to start the  cluster"


docker stack deploy -c docker-compose.yml sock-shop

started=false

until $started; do
	docker stack services sock-shop --format "{{.Replicas}}" 2>/dev/null | grep '0/' >/dev/null && started=true || true
done

sleep 150 
curl -f -s -o /dev/null -w "%{http_code}" -H "Authorization: Basic dXNlcjpwYXNzd29yZA==" `./get_ip.sh`/login &&
	curl -f -s -w "%{http_code}" -o /dev/null `./get_ip.sh `/catalogue ||
       		./restart.sh $((attempt + 1))

