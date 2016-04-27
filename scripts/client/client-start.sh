#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "error: need 3 parameters. "
    exit 1
fi

CLIENT_PATH=$1
CLIENT_NUM=$2
CLIENT_INTERVAL=$3

CLIENT_DIR=$(dirname $CLIENT_PATH)
CLIENT_EXE=$(basename $CLIENT_PATH)

echo "CLIENT_DIR: $CLIENT_DIR"
echo "CLIENT_EXE: $CLIENT_EXE"
echo "CLIENT_NUM: $CLIENT_NUM"

NUMBER_REGEX='^[0-9]+$'

if ! [[ $CLIENT_NUM =~ $NUMBER_REGEX ]] ; then
    echo "Invalid client num."
    exit 1
fi

cd $CLIENT_DIR

for i in $(seq $CLIENT_NUM); do
    echo "Start client $i"
    # note that Unreal will refuse to run as ROOT
    sudo -u ubuntu nohup ./$CLIENT_EXE > /dev/null 2>&1 &
    sleep $CLIENT_INTERVAL
done
