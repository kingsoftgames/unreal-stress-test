#!/bin/bash

#
# Add this script to crontab with command:
#
# crontab -e
#
# 1-minute interval
# * * * * * [path to cloudwatch-put-metric-data.sh] [path to data file] [region]
# 

DATA_FILE=$1
REGION=$2
PROCESS_NAME=$3

AWS_HOME='/usr/local/bin'
CURL_HOME='/usr/bin'
EC2METADATA_HOME='/usr/bin'

CLOUDWATCH="$AWS_HOME/aws cloudwatch put-metric-data --region $REGION"

source $DATA_FILE
COUNT=$STRESS_TEST_CLIENT_COUNT
TIMESTAMP=$STRESS_TEST_UNIX_TIMESTAMP

NUMBER_REGEX='^[0-9]+$'

if ! [[ $COUNT =~ $NUMBER_REGEX ]] ; then
    echo "Unable to get client count."
    exit 1
fi

NOW=$(date +%s)
DIFF=$(expr $NOW - $TIMESTAMP)

if [ "$DIFF" -gt "10" ]; then
    echo "Timestamp outdated."
    exit 2
fi

# get ec2 instance id
INSTANCE_ID=`$EC2METADATA_HOME/ec2metadata  --instance-id`

$CLOUDWATCH \
    --namespace "ROG2/UEServerStressTest" \
    --dimensions "InstanceId=$INSTANCE_ID" \
    --metric-name "Client" \
    --unit "Count" \
    --value "$COUNT"

CPU_PERCENT=$(ps aux | grep $PROCESS_NAME | grep -v grep | awk {'print $3'})

if [ -z "$CPU_PERCENT" ]; then
    echo "No CPU usage with process $PROCESS_NAME"
    exit 3
fi

$CLOUDWATCH \
    --namespace "ROG2/UEServerStressTest" \
    --dimensions "InstanceId=$INSTANCE_ID" \
    --metric-name "CPU" \
    --unit "Percent" \
    --value "$CPU_PERCENT"
