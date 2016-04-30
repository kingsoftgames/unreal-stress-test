#!/bin/bash

set -e

env=$1

if [ "$#" -ne 1 ]; then
    echo "Usage: terminate-clients.sh [env]"
    exit 1
fi

cd $(dirname "$0")

source scripts/common/functions.sh

load_conf client $env

echo -e "Finding game client instances in \033[92m$REGION\033[0m region ..."

terminate_instances client

