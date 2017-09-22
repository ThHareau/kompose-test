#!/bin/bash
set -e

function print_line {
	throughput=$1
	latency=$2
	stdev=$3
	printf "%10s\t%10s\t%10s\n" $throughput $latency $stdev
}

function restart_cluster {
	ret=`./install.sh $CLUSTER_MANAGER 2>&1` && succeed=true || succeed=false
	
	retries=0
	while  ! $succeed  && [ $retries -lt 5 ]; do 
		sleep 30
		ret=`./install.sh $CLUSTER_MANAGER --fast 2>&1` && succeed=true || ((++retries))
	done

	if ! $succeed; then
		>&2 echo "Failure while restarting cluster"
		>&2 echo "$ret"
		restart_cluster 
	fi
}

if [ "$#" -lt "3" ]; then
	echo "Three required argument"
	echo "Usage: ./wrk_tput <bench_manager> <cluster_manager> <cookie file> [throughput file]"
	exit 1
fi

MANAGER=$1
CLUSTER_MANAGER=$2
URL_FILE="url.ip"
COOKIE_FILE=$3
THROUGHPUT_FILE=$4

if [[ ! -f $COOKIE_FILE ]]; then
	>&2 echo "No cookie file provided, please use \"./install.sh $CLUSTER_MANAGER\" to get it" 
	exit 0
fi

if [[ -f $THROUGHPUT_FILE ]]; then 
	IFS=$'\n' read -d '' -r -a throughput < $THROUGHPUT_FILE
else
	throughput=()
	for i in `seq 1 5`; do
		for j in `seq 1 2 10`; do 
			throughput+=( $((10**i*j)) )
		done
	done

fi


>&2 echo "The cluster will be reset! Sleeping 5 seconds to let you abort"
# sleep 5


if ! ssh -n $MANAGER "command -v wrk >/dev/null 2>&1 "  ; then
		echo "Please install wrk2 on manager"
		echo "See: https://github.com/giltene/wrk2/wiki/Installing-wrk2-on-Linux"
		exit 1;
fi
scp "`pwd`/post.lua" $MANAGER:/tmp  >/dev/null 2>&1 

echo "${throughput[@]}"


printf "#Throughput\tLatency\tStdDeviation\n"
for tgpt in "${throughput[@]}"; do
	>&2 echo "Starting test $tgpt"
	restart_cluster 

	sleep 10


	>&2 echo "$tgpt: Reading cookie"
	# get new cookie, and new URL
	cookie=`cat $COOKIE_FILE`
	url=`cat $URL_FILE`

	# init... 

	>&2 echo "$tgpt: launching load test"
	ssh -n $MANAGER "docker run --net=host weaveworksdemos/load-test -h $url -r 100 -c 2  > /dev/null 2>&1" || true

	>&2 echo "$tgpt: launching wrk"
	res=$(ssh -n $MANAGER "wrk -t2 -c100 -d120s -R$tgpt -H \"Cookie: $cookie\" -s /tmp/post.lua --latency http://$url/orders 2>&1") 
	# latency="13456"
	# std="564"
	>&2 echo "$tgpt: analysing result"
	read latency std <<<  $( printf "%s" "$res"  | awk '/\#\[Mean/ {print $3 $6}'  | tr ",]" " " )
	print_line $tgpt $latency $std
	echo "------------ $tgpt: $latency [+- $std] ---------------" >> res.txt
	printf "%s\n" "$res" >> res.txt
done

printf  "$throughput"
