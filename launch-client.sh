#!/bin/bash

set -e

REGION=$1
EC2_COUNT=$2

if [ "$#" -ne 2 ]; then
    echo "Usage: launch-client.sh [region] [ec2-count]"
    exit 1
fi

cd $(dirname "$0")

source conf/$REGION/common.conf
source conf/$REGION/client.conf

echo "Launching $EC2_COUNT instances with $EC2_LAUNCH_INTERVAL seconds interval ..."

for i in `seq 1 $EC2_COUNT`;
do

# give some green color see-see
echo -e "\033[0;32mLaunching instance No. $i ...\033[0m"

OUTPUT=$(aws ec2 run-instances \
    --region $REGION \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SECURITY_GROUPS \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
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
        Key=server-or-client,Value=client \
        Key=package-url,Value=$PACKAGE_URL

echo "Instance tagged successfully."


# wait for next launch
for i in `seq 1 $EC2_LAUNCH_INTERVAL`;
do
    sleep 1
    echo -ne "Waiting for next launch: $i / $EC2_LAUNCH_INTERVAL\r"
done
echo ''

done