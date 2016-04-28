#!/bin/bash

set -e

REGION=$1

if [ "$#" -ne 1 ]; then
    echo "Usage: terminate-clients.sh [region]"
    exit 1
fi

cd $(dirname "$0")

source conf/$REGION/common.conf
source conf/$REGION/client.conf

source scripts/common/functions.sh

echo -e "Finding game client instances in \033[92m$REGION\033[0m region ..."

terminate_instances client

