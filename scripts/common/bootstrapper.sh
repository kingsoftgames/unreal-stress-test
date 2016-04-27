#!/bin/bash

export RUN_DIR=$1

cd $(dirname "$0")

source functions.sh

export REGION=$(get_region)
export SERVER_OR_CLIENT=$(get_tag server-or-client)
PACKAGE_URL=$(get_tag package-url)

# automatically export all variables in conf files
set -a
    source ../../conf/$REGION/common.conf
    source ../../conf/$REGION/$SERVER_OR_CLIENT.conf
set +a

PACKAGE_FILENAME=$(basename $PACKAGE_URL)

# download package from S3
aws s3 cp $PACKAGE_URL $RUN_DIR/$PACKAGE_FILENAME --region $REGION

pushd $RUN_DIR
    tar xzvf $PACKAGE_FILENAME
    chown -R ubuntu:ubuntu *
popd

# run server/client logic
../$SERVER_OR_CLIENT/run.sh
