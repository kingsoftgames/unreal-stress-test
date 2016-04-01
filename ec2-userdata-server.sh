#!/bin/bash

su ubuntu

cd ~/rog2/LinuxServer/ROG2New/Binaries/Linux
nohup ./ROG2NewServer > /dev/null 2>&1 &
