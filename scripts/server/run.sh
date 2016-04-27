#!/bin/bash

cd $(dirname "$0")

# Increase UDP socket buffer
sudo sysctl net.core.rmem_max=$SOCKET_BUFFER_MAX
sudo sysctl net.core.wmem_max=$SOCKET_BUFFER_MAX

pushd $RUN_DIR/$BINARY_FOLDER
    nohup ./$BINARY_NAME > /dev/null 2>&1 &
popd

nohup ./cloudwatch-scheduler.sh  > /dev/null 2>&1 &
