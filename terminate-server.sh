#!/bin/bash

set -e

env=$1

if [ "$#" -ne 1 ]; then
    echo "Usage: terminate-server.sh [env]"
    exit 1
fi

cd $(dirname "$0")

source scripts/common/functions.sh

load_conf server $env

echo -e "Finding dedicated server instances in \033[92m$REGION\033[0m region ..."

terminate_instances server
