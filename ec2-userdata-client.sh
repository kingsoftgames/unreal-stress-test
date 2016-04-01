#!/bin/bash

CLIENT_PATH=/home/ubuntu/rog2/LinuxNoEditor/ROG2New/Binaries/Linux/ROG2New
CLIENT_COUNT=6

cd /home/ubuntu/rog2/ueserver-stress-test
sudo -u ubuntu ./client_start.sh $CLIENT_PATH $CLIENT_COUNT
