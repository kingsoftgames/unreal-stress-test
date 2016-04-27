#!/bin/bash

cd $(dirname "$0")

pushd $RUN_DIR/$BINARY_FOLDER
    nohup ./$BINARY_NAME > /dev/null 2>&1 &
popd

nohup ./cloudwatch-scheduler.sh  > /dev/null 2>&1 &
