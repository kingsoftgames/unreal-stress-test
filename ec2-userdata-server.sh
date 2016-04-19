#!/bin/bash

cd /home/ubuntu/rog2/LinuxServer/ROG2New/Binaries/Linux
sudo -u ubuntu nohup ./ROG2NewServer > /dev/null 2>&1 &
sudo -u ubuntu nohup watch '/home/ubuntu/rog2/ueserver-stress-test/cloudwatch-put-metric-data.sh /home/ubuntu/rog2/LinuxServer/ROG2New/ClientCount.txt us-east-1 ROG2NewServer'  > /dev/null 2>&1 &
