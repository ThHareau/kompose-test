#!/bin/bash
set -e

if [[ "$#" -lt 1 ]]; then 
	echo "Usage: ./install.sh <cluster_manager> [--fast]"
	exit 1
fi

MANAGER=$1
POSSIBLE_FILE="possible.cookie"
IMPOSSIBLE_FILE="impossible.cookie"
URL_FILE="url.ip"
FAST=$2


function login {
	auth=`printf $1 | base64`
	resource="$URL/login"

	>&2 echo "> login $resource"
	res=`ssh -n $MANAGER "curl --fail -s -i -H \"Authorization: Basic $auth\" \"$resource\""` 
	cookie=$(awk 'tolower($0) ~ /set-cookie: [^_]/{ print $2 }' <<< $res  | tr '\n' ' ')
	>&2 echo "< login"
}

function delete_cart {
	>&2 echo "> delete_cart $URL/cart "
	cookie=$1
	ssh -n $MANAGER "curl -f -s -H \"Cookie: $cookie\" $URL/cart -XDELETE > /dev/null 2>1"
	>&2 echo "< delete_cart"
}

function get_colourful {
	>&2 echo "> get_colourful $URL/catalogue"
	cookie=$1
	result=`ssh -n $MANAGER "curl --fail -s -H \"Cookie: $cookie\" $URL/catalogue" | grep -v "error"`
	>&2 echo "$result"

	failure=false
	colourful_id=`echo "$result" | python -c "import sys, json; print([l['id'] for l in json.load(sys.stdin) if l['name'] == 'Colourful'][0])"` || failure=true
	if $failure ; then
		>&2 echo "$failure: $result"
		return 1
	fi
	>&2 echo "< get_colourful "
}

function post_cart {
	>&2 echo "> post_cart $URL/cart"
	cookie=$1
	id=$2
	number=$3
	for i in `seq 1 $number`; do
		ssh -n $MANAGER "curl --fail -s $URL/cart -H \"Cookie: $cookie\" -H \"Content-Type: application/json\"  -d  \"{\\\"id\\\":\\\"$id\\\"}\"> /dev/null 2>1" 	
	done
	>&2 echo "< post_cart "
}

rm $URL_FILE > /dev/null 2>&1 || true 
rm $POSSIBLE_FILE > /dev/null 2>&1 || true
rm $IMPOSSIBLE_FILE > /dev/null 2>&1 || true

if [[ $FAST != "--fast" ]]; then 
# restart cluster
	errors=`ssh -n $MANAGER "./restart.sh 2>&1"`
fi

URL=`ssh -n $MANAGER ./get_ip.sh`

function init {
# log us
	login "user:password"
	order_possible=`echo $cookie | sed "s/ //g"`

	login "user1:password"
	order_impossible=`echo $cookie | sed "s/ //g"`

	echo "$URL" > "$URL_FILE"
	echo "$order_possible" > "$POSSIBLE_FILE"
	echo "$order_impossible" > "$IMPOSSIBLE_FILE"


	get_colourful "$order_possible" 

	delete_cart "$order_possible"
	delete_cart "$order_impossible"

	post_cart "$order_possible" "$colourful_id" 4

	post_cart "$order_impossible" "$colourful_id" 10
}

success=false
retries=0
while ! $success && [ "$retries" -lt 5 ]; do
        res=`init 2>&1` && success=true || ((++retries))
        $success || >&2 echo "### attempt $retries ###"
        $success || >&2 echo "### $res ###"
        $success || sleep 15
done
if ! $success; then
		>&2
        >&2 echo "Failure to install cluster. Exiting"
        return 1
fi


echo "The URL has been written in $URL_FILE
The cookie for the possible order has been written in $POSSIBLE_FILE
The cookie for the impossible order has been has been written in $IMPOSSIBLE_FILE"

echo "
Unsure a restart.sh is available at the root of <CLUSTER_MANAGER>
Now you can run: ./wrk_tput.sh <BENCH_MANAGER> $MANAGER $POSSIBLE_FILE
./wrk_tput.sh <BENCH_MANAGER> $MANAGER  $IMPOSSIBLE_FILE"

