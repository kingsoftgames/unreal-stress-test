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

AWS_HOME='/usr/local/bin'
CURL_HOME='/usr/bin'
EC2METADATA_HOME='/usr/bin'

CLOUDWATCH="$AWS_HOME/aws cloudwatch put-metric-data --region $REGION"

COUNT=$(cat $DATA_FILE)

NUMBER_REGEX='^[0-9]+$'

if ! [[ $COUNT =~ $NUMBER_REGEX ]] ; then
    echo "Unable to get client count."
    exit 1
fi

# get ec2 instance id
INSTANCE_ID=`$EC2METADATA_HOME/ec2metadata  --instance-id`

$CLOUDWATCH \
    --namespace "ROG2/UEServerStressTest" \
    --dimensions "InstanceId=$INSTANCE_ID" \
    --metric-name "Client" \
    --unit "Count" \
    --value "$COUNT"