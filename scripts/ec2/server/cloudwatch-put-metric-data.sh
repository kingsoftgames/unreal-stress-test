#!/bin/bash

AWS_HOME='/usr/local/bin'
CURL_HOME='/usr/bin'
EC2METADATA_HOME='/usr/bin'

data_file=$1
region=$2
process_name=$3
namespace=$4

cloudwatch="$AWS_HOME/aws cloudwatch put-metric-data --region $region"

source $data_file
count=$STRESS_TEST_CLIENT_COUNT
timestamp=$STRESS_TEST_UNIX_TIMESTAMP

NUMBER_REGEX='^[0-9]+$'

if ! [[ $count =~ $NUMBER_REGEX ]] ; then
    echo "Unable to get client count."
    exit 1
fi

now=$(date +%s)
diff=$(expr $now - $timestamp)

if [ "$diff" -gt "30" ]; then
    echo "Timestamp outdated."
    exit 2
fi

echo "count: $count"

# get ec2 instance id
instance_id=$($EC2METADATA_HOME/ec2metadata  --instance-id)

$cloudwatch \
    --namespace "$namespace" \
    --dimensions "InstanceId=$instance_id" \
    --metric-name "Client" \
    --unit "Count" \
    --value "$count"

# make sure top does not limit output (e.g. ROG2NewServer becomes ROG2NewSer+)
export COLUMNS=1000
cpu_percent=$(top -b -n 1 -p `pgrep $process_name` | grep $process_name | awk {'print $9'})

echo "CPU percent: $cpu_percent"

if [ -z "$cpu_percent" ]; then
    echo "No CPU usage with process $process_name"
    exit 3
fi

$cloudwatch \
    --namespace "$namespace" \
    --dimensions "InstanceId=$instance_id" \
    --metric-name "CPU" \
    --unit "Percent" \
    --value "$cpu_percent"
