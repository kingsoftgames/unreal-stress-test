#!/bin/bash
#
# Common functions used by both server and client.
#

EC2_METADATA_URL=http://169.254.169.254/latest/dynamic/instance-identity/document

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
