#!/bin/bash

cd $(dirname "$0")

while true; do

sudo -u ubuntu ./cloudwatch-put-metric-data.sh \
        $RUN_DIR/$CLIENT_COUNT_DATA_FILE \
        $REGION \
        $BINARY_NAME \
        $CLOUDWATCH_NAMESPACE \
    >> $RUN_DIR/cloudwatch.log 2>&1

sleep $PUT_METRIC_INTERVAL

done