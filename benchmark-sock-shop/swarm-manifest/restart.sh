#!/bin/bash
set -e

attempt=${1:-1}

./stop.sh
./start.sh $attempt
