#!/bin/bash

USER_DATA=file://scripts/ec2/userdata.sh

function load_conf() {
    local server_or_client=$1
    local env=$2
    
    source conf/_default/common.conf
    source conf/_default/$server_or_client.conf

    source conf/$env/common.conf
    source conf/$env/$server_or_client.conf
}

function run_instance() {
    local server_or_client=$1
    
    local placement="Tenancy=$TENANCY"
    local block_device_mapping="[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":$EBS_SIZE,\"DeleteOnTermination\":true,\"VolumeType\":\"gp2\"}}]"
    
    local params="
        --profile $AWSCLI_PROFILE
        --region $REGION
        --subnet-id $SUBNET_ID
        --security-group-ids $SECURITY_GROUPS
        --image-id $IMAGE_ID
        --instance-type $INSTANCE_TYPE
        --placement $placement
        --block-device-mapping $block_device_mapping
        --key-name $KEY_NAME
        --iam-instance-profile Name=$IAM_INSTANCE_PROFILE
        --user-data $USER_DATA
        --output json
        "
    
    if [ "$server_or_client" = "server" ]
    then
        params+="--private-ip-address $PRIVATE_IP_ADDRESS"
    fi
    
    local output=$(aws ec2 run-instances $params)
    
    local instance_id=$(echo "$output" | jq .Instances[0].InstanceId -r)
    echo $instance_id
}

function tag_instance() {
    local server_or_client=$1
    local env=$2
    local instance_id=$3
    
    local params="
        --profile $AWSCLI_PROFILE
        --region $REGION
        --resources $instance_id
        --tags
            Key=name,Value=$INSTANCE_NAME
            Key=env,Value=$env
            Key=server-or-client,Value=$server_or_client
            Key=package-url,Value=$PACKAGE_URL
            Key=exec-params,Value=\""$EXEC_PARAMS"\""
    
    aws ec2 create-tags $params
}

function wait_for_instance_ready() {
    local instance_id=$1

    while state=$(aws ec2 describe-instances \
        --profile $AWSCLI_PROFILE \
        --region $REGION \
        --instance-ids $instance_id \
        --query 'Reservations[*].Instances[*].State.Name' \
        --output text); test "$state" = "pending"; do
            sleep 1; echo -n '.'
    done; echo " $state"
}

function get_instance_public_ip_address() {
    local instance_id=$1
    
    aws ec2 describe-instances \
        --profile $AWSCLI_PROFILE \
        --region $REGION \
        --instance-ids $instance_id \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        --output text
}

function terminate_instances() {
    local server_or_client=$1
    
    local params="
        --profile $AWSCLI_PROFILE
        --region $REGION
        --filters
            "Name=instance-state-name,Values=running"
            "Name=tag:name,Values=$INSTANCE_NAME"
            "Name=tag:server-or-client,Values=$server_or_client"
        --output json
        "
    
    local output=$(aws ec2 describe-instances $params)
        
    local instance_ids=$(echo "$output" | jq .Reservations[].Instances[].InstanceId -r)

    # use sed to trim spaces
    local count=$(echo $instance_ids | wc -w | sed -e 's/^[ \t]*//')

    if [ "$count" -gt "0" ]
    then
        echo "The following instances will be terminated:"
        for i in $instance_ids;
        do
            echo -e "\033[92m$i\033[0m"
        done
        echo "Terminating $count instances."

        output=$(aws ec2 terminate-instances \
            --profile $AWSCLI_PROFILE \
            --region $REGION \
            --instance-ids $instance_ids \
            --output json)
    else
        echo "No instance to be terminated."
    fi
}