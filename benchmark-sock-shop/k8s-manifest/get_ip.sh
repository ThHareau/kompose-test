#!/bin/bash
set -e

port=`kubectl get -n sock-shop svc front-end |grep "front-end" | python -c 'import re,sys; s=sys.stdin.readline(); print(re.search("\d{2}:(3\d{4})",s).group(1))'`
ip=`ip addr show ens3 | grep -Po 'inet \K[\d.]+'`

echo "$ip:$port"
