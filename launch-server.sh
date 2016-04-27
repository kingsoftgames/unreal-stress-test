#!/bin/bash

set -e

REGION=$1

if [ -z "$REGION" ]; then
    echo "Usage: launch-server.sh [region]"
    exit 1
fi

cd $(dirname "$0")

source conf/$REGION/common.conf
source conf/$REGION/server.conf

echo "Launching dedicated server on EC2 ..."

OUTPUT=$(aws ec2 run-instances \
    --region $REGION \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SECURITY_GROUPS \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --private-ip-address $PRIVATE_IP_ADDRESS \
    --iam-instance-profile Name=$IAM_INSTANCE_PROFILE \
    --user-data file://scripts/common/ec2-userdata.sh \
    --output json)

# echo "$OUTPUT"

INSTANCE_ID=$(echo "$OUTPUT" | jq .Instances[0].InstanceId -r)

echo "Instance $INSTANCE_ID launched."

echo "Tagging instance $INSTANCE_ID ..."
    
aws ec2 create-tags \
    --region $REGION \
    --resources $INSTANCE_ID \
    --tags \
        Key=name,Value=$INSTANCE_NAME \
        Key=server-or-client,Value=server \
        Key=package-url,Value=$PACKAGE_URL

echo "Instance tagged successfully."
