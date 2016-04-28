#!/bin/bash

set -e

REGION=$1

if [ "$#" -ne 1 ]; then
    echo "Usage: terminate-server.sh [region]"
    exit 1
fi

cd $(dirname "$0")

source conf/$REGION/common.conf
source conf/$REGION/server.conf

source scripts/common/functions.sh

echo -e "Finding dedicated server instances in \033[92m$REGION\033[0m region ..."

terminate_instances server
