#!/bin/bash
set -e

# tests are long. You may want to launch them on a dedicated machine, using nohup. To do so: 

# nohup sh -c "./exec.sh bench thomas@hareau.eu ; csmail -s \"Benchmark finished with status $?\" nohup.out \"thomas@hareau.eu\""

BENCH=${1:-bench} # the machine from which running wrk2
EMAIL=$2 # if present, csmail will be used to sent you an email
THROUGHPUT=$2 # if none, default is kept

ssh k8s-master ./stop.sh
ssh swarm-master ./stop.sh
ssh real-k8s-master ./stop.sh

function launch {
	master=$1
	cookie=$2
	( ./install.sh $master || ./install.sh $master --fast ) 2>&1 | tee "${master}-${cookie}.install"
	( ./wrk_tput.sh $BENCH $master ${cookie}.cookie $THROUGHPUT | tee "${master}-${cookie}.install" ) 2>&1 | tee "${master}-${cookie}.logs"
	mv res.txt "${master}-${cookie}.res"
	if [[ -n $EMAIL ]]; then
		csmail send -s "Bench ${master} for ${cookie} finished" "${master}-${cookie}.logs" "$EMAIL"
	done

}

time launch k8s-master possible
time launch k8s-master impossible

time launch swarm-master possible
time launch swarm-master impossible

time launch real-k8s-master possible
time launch real-k8s-master impossible


