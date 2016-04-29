#!/bin/bash
#
# Common functions used by both server and client.
#

EC2_METADATA_URL=http://169.254.169.254/latest/dynamic/instance-identity/document
USER_DATA=file://scripts/common/ec2-userdata.sh

function load_conf() {
    local SERVER_OR_CLIENT=$1
    local ENV=$2
    
    source conf/_default/common.conf
    source conf/_default/$SERVER_OR_CLIENT.conf

    source conf/$ENV/common.conf
    source conf/$ENV/$SERVER_OR_CLIENT.conf
}

function get_instance_id() {
    curl -s $EC2_METADATA_URL | jq .instanceId -r
}

function get_region() {
    curl -s $EC2_METADATA_URL | jq .region -r
}

function get_tag() {
    local TAG_KEY=$1
    
    local REGION=$(get_region)
    local INSTANCE_ID=$(get_instance_id)
    
    aws ec2 describe-tags \
        --region $REGION \
        --filters \
            "Name=resource-id,Values=$INSTANCE_ID" \
            "Name=key,Values=$TAG_KEY" \
        --query "Tags[0].Value" \
        --output text
}

function run_instance() {
    local SERVER_OR_CLIENT=$1
    
    local BLOCK_DEVICE_MAPPING="[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":$EBS_SIZE,\"DeleteOnTermination\":true,\"VolumeType\":\"gp2\"}}]"
    
    local PARAMS="
        --profile $AWSCLI_PROFILE
        --region $REGION
        --subnet-id $SUBNET_ID
        --security-group-ids $SECURITY_GROUPS
        --image-id $IMAGE_ID
        --instance-type $INSTANCE_TYPE
        --block-device-mapping $BLOCK_DEVICE_MAPPING
        --key-name $KEY_NAME
        --iam-instance-profile Name=$IAM_INSTANCE_PROFILE
        --user-data $USER_DATA
        --output json
        "
    
    if [ "$SERVER_OR_CLIENT" = "server" ]
    then
        PARAMS+="--private-ip-address $PRIVATE_IP_ADDRESS"
    fi
    
    local OUTPUT=$(aws ec2 run-instances $PARAMS)
    
    local INSTANCE_ID=$(echo "$OUTPUT" | jq .Instances[0].InstanceId -r)
    echo $INSTANCE_ID
}

function tag_instance() {
    local SERVER_OR_CLIENT=$1
    local ENV=$2
    local INSTANCE_ID=$3
    
    local PARAMS="
        --profile $AWSCLI_PROFILE
        --region $REGION
        --resources $INSTANCE_ID
        --tags
            Key=name,Value=$INSTANCE_NAME
            Key=env,Value=$ENV
            Key=server-or-client,Value=$SERVER_OR_CLIENT
            Key=package-url,Value=$PACKAGE_URL
        "
    
    aws ec2 create-tags $PARAMS
}

function wait_for_instance_ready() {
    local INSTANCE_ID=$1

    while INSTANCE_STATE=$(aws ec2 describe-instances \
        --profile $AWSCLI_PROFILE \
        --region $REGION \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[*].Instances[*].State.Name' \
        --output text); test "$INSTANCE_STATE" = "pending"; do
            sleep 1; echo -n '.'
    done; echo " $INSTANCE_STATE"
}

function get_instance_public_ip_address() {
    local INSTANCE_ID=$1
    
    aws ec2 describe-instances \
        --profile $AWSCLI_PROFILE \
        --region $REGION \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        --output text
}

function terminate_instances() {
    local SERVER_OR_CLIENT=$1
    
    local PARAMS="
        --profile $AWSCLI_PROFILE
        --region $REGION
        --filters
            "Name=instance-state-name,Values=running"
            "Name=tag:name,Values=$INSTANCE_NAME"
            "Name=tag:server-or-client,Values=$SERVER_OR_CLIENT"
        --output json
        "
    
    local OUTPUT=$(aws ec2 describe-instances $PARAMS)
        
    local INSTANCE_IDS=$(echo "$OUTPUT" | jq .Reservations[].Instances[].InstanceId -r)

    # use sed to trim spaces
    local COUNT=$(echo $INSTANCE_IDS | wc -w | sed -e 's/^[ \t]*//')

    if [ "$COUNT" -gt "0" ]
    then
        echo "The following instances will be terminated:"
        for i in $INSTANCE_IDS;
        do
            echo -e "\033[92m$i\033[0m"
        done
        echo "Terminating $COUNT instances."

        OUTPUT=$(aws ec2 terminate-instances \
            --profile $AWSCLI_PROFILE \
            --region $REGION \
            --instance-ids $INSTANCE_IDS \
            --output json)
    else
        echo "No instance to be terminated."
    fi
}