#!/bin/bash

CLIENT_PATH=~/rog2/LinuxNoEditor/ROG2New/Binaries/Linux/ROG2New
CLIENT_COUNT=6

su ubuntu
cd ~/rog2/ueserver-stress-test
./client_start.sh $CLIENT_PATH $CLIENT_COUNT
