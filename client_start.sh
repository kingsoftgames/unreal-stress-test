#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "error: need 2 parameters. "
    exit 1
fi

CLIENT_PATH=$1
CLIENT_NUM=$2

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
    nohup ./$CLIENT_EXE > /dev/null 2>&1 &
done
