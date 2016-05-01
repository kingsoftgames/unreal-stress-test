#!/bin/bash
#
# Common functions used by both server and client.
#

EC2_METADATA_URL=http://169.254.169.254/latest/dynamic/instance-identity/document

function load_conf() {
    local server_or_client=$1
    local env=$2
    
    # automatically export all variables in conf files
    set -a
        source ../../conf/_default/common.conf
        source ../../conf/_default/$server_or_client.conf

        source ../../conf/$env/common.conf
        source ../../conf/$env/$server_or_client.conf
    set +a
}

function get_instance_id() {
    curl -s $EC2_METADATA_URL | jq .instanceId -r
}

function get_region() {
    curl -s $EC2_METADATA_URL | jq .region -r
}

function get_tag() {
    local tag_key=$1
    
    local region=$(get_region)
    local instance_id=$(get_instance_id)
    
    aws ec2 describe-tags \
        --region $region \
        --filters \
            "Name=resource-id,Values=$instance_id" \
            "Name=key,Values=$tag_key" \
        --query "Tags[0].Value" \
        --output text
}
