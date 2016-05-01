#!/bin/bash

set -e

env=$1
ec2_count=$2

if [ "$#" -ne 2 ]; then
    echo "Usage: launch-all.sh [env] [client-ec2-count]"
    exit 1
fi

cd $(dirname "$0")

./launch-server.sh $env

./launch-clients.sh $env $ec2_count
