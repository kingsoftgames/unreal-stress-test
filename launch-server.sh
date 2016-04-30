#!/bin/bash

set -e

env=$1

if [ -z "$env" ]; then
    echo "Usage: launch-server.sh [env]"
    exit 1
fi

cd $(dirname "$0")

source scripts/common/functions.sh

load_conf server $env

echo -e "Launching dedicated server on \033[92m$INSTANCE_TYPE\033[0m instance in \033[92m$REGION\033[0m region ..."

instance_id=$(run_instance server)

echo -e "Instance \033[92m$instance_id\033[0m launched."

echo "Tagging instance ..."

tag_instance server $env $instance_id

echo "Instance tagged successfully."

echo "Waiting for the instance to become ready ..."

wait_for_instance_ready $instance_id

public_ip_address=$(get_instance_public_ip_address $instance_id)

echo -e "Public IP address: \033[92m$public_ip_address\033[0m"

# echo "Testing server UDP port $UDP_PORT ..."
# nc -uv $public_ip_address $UDP_PORT

echo -e "\033[92mInstance launched successfully.\033[0m"
