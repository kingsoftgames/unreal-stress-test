#!/bin/bash

cd $(dirname "$0")

while true; do

./cloudwatch-put-metric-data.sh \
    $RUN_DIR/$CLIENT_COUNT_DATA_FILE $REGION $BINARY_NAME \
    >> $RUN_DIR/cloudwatch-put-metric-data.log 2>&1

sleep $PUT_METRIC_INTERVAL

done