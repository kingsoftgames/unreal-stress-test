#!/bin/bash

set -e

env=$1
ec2_count=$2

if [ "$#" -ne 2 ]; then
    echo "Usage: launch-clients.sh [env] [ec2-count]"
    exit 1
fi

cd $(dirname "$0")

source scripts/common/functions.sh

load_conf client $env

echo -e "Launching game client on \033[92m$INSTANCE_TYPE\033[0m instances in \033[92m$REGION\033[0m region ..."
echo -e "Total \033[92m$ec2_count\033[0m instances, with \033[92m$EC2_LAUNCH_INTERVAL\033[0m seconds interval."

for i in `seq 1 $ec2_count`;
do

# give some green color see-see
echo -e "\033[92mLaunching instance No.$i ...\033[0m"

instance_id=$(run_instance client)

echo "Instance $instance_id launched."

echo "Tagging the instance ..."

tag_instance client $env $instance_id

echo "Instance tagged successfully."

# wait for next launch
if [ "$i" -ne "$ec2_count" ]; then
    for i in `seq 1 $EC2_LAUNCH_INTERVAL`;
    do
        sleep 1
        echo -ne "Waiting for next launch: \033[91m`expr 10 - $i`\033[0m\r"
    done
    echo -ne "\r"
fi

done

echo -e "\033[92mAll Instances launched successfully.\033[0m"
