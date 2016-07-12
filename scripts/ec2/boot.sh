#!/bin/bash

INSTANCE_STORE_DEVICE=/dev/xvdb

export RUN_DIR=$1

cd $(dirname "$0")

source functions.sh

env=$(get_tag env)
server_or_client=$(get_tag server-or-client)
package_url=$(get_tag package-url)
exec_params=$(get_tag exec_params)

load_conf $server_or_client $env

package_filename=$(basename $package_url)

# Run in instance store if available for better performance.
if [ -b "$INSTANCE_STORE_DEVICE" ]
then
    mount_point=$(lsblk -n -o MOUNTPOINT $INSTANCE_STORE_DEVICE)
    export RUN_DIR=$mount_point
fi

# download package from S3
aws s3 cp $package_url $RUN_DIR/$package_filename --region $REGION

pushd $RUN_DIR
    tar xzvf $package_filename
    chown -R ubuntu:ubuntu *
popd

export EXEC_PARAMS="$exec_params"

# run server/client logic
./$server_or_client/run.sh >> $RUN_DIR/run.log 2>&1
