#!/bin/bash

export RUN_DIR=$1

cd $(dirname "$0")

source functions.sh

env=$(get_tag env)
server_or_client=$(get_tag server-or-client)
package_url=$(get_tag package-url)

# automatically export all variables in conf files
set -a
    source ../../conf/_default/common.conf
    source ../../conf/_default/$server_or_client.conf

    source ../../conf/$env/common.conf
    source ../../conf/$env/$server_or_client.conf
set +a

package_filename=$(basename $package_url)

# download package from S3
aws s3 cp $package_url $RUN_DIR/$package_filename --region $REGION

pushd $RUN_DIR
    tar xzvf $package_filename
    chown -R ubuntu:ubuntu *
popd

# run server/client logic
../$server_or_client/run.sh
