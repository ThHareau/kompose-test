#!/bin/bash
ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
port=$(kubectl describe svc edge-router | grep -v 8080 | awk '/NodePort:/ { print $3 }' | sed 's/\/TCP//g' )
echo "$ip:$port"
