#!/bin/bash

set -e

ENV=$1

if [ -z "$ENV" ]; then
    echo "Usage: launch-server.sh [env]"
    exit 1
fi

cd $(dirname "$0")

source scripts/common/functions.sh

load_conf server $ENV

echo -e "Launching dedicated server on \033[92m$INSTANCE_TYPE\033[0m instance in \033[92m$REGION\033[0m region ..."

INSTANCE_ID=$(run_instance server)

echo -e "Instance \033[92m$INSTANCE_ID\033[0m launched."

echo "Tagging instance ..."

tag_instance server $ENV $INSTANCE_ID

echo "Instance tagged successfully."

echo "Waiting for the instance to become ready ..."

wait_for_instance_ready $INSTANCE_ID

PUBLIC_IP_ADDRESS=$(get_instance_public_ip_address $INSTANCE_ID)

echo -e "Public IP address: \033[92m$PUBLIC_IP_ADDRESS\033[0m"

# echo "Testing server UDP port $UDP_PORT ..."
# nc -uv $PUBLIC_IP_ADDRESS $UDP_PORT

echo -e "\033[92mInstance launched successfully.\033[0m"
