#!/bin/bash

set -e

env=$1

if [ "$#" -ne 1 ]; then
    echo "Usage: terminate-all.sh [env]"
    exit 1
fi

cd $(dirname "$0")

./terminate-clients.sh $env

./terminate-server.sh $env