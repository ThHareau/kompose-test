#!/bin/bash
set -e

attempt=${1:-0}


./stop.sh
./start.sh $attempt
