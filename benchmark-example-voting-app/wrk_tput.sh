#!/bin/bash
set -e


function print_line {
	throughput=$1
	latency=$2
	stdev=$3
	printf "%10s\t%10s\t%10s\n" $throughput $latency $stdev
}

if [ "$#" -lt "1" ]; then
	echo "One required argument (url)"
	exit 1
fi

if [[ -f $2 ]]; then 
	throughput=`cat "$2"`
else
	throughput=""
	for i in `seq 1 5`; do
		for j in `seq 1 2 10`; do 
			throughput+="$(printf "%s\n" $((10**i*j)))\n"
		done
	done

fi

echo  "$throughput"

printf "#Throughput\tLatency\tStdDeviation\n"
while IFS='' read -r tgpt || [[ -n "$tgpt" ]]; do
	res=$(wrk -t2 -c100 -d30s -R$tgpt --latency $1 2>&1)
	read latency std <<<  $( printf "%s" "$res"  | awk '/\#\[Mean/ {print $3 $6}'  | tr ",]" " " )
	print_line $tgpt $latency $std
	echo "------------ $tgpt: $latency [+- $std] ---------------" >> res.txt
	printf "%s\n" "$res" >> res.txt
done <<< `printf "$throughput"`