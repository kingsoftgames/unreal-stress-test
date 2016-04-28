#!/bin/bash
HOME_DIR=/opt/rog2
RUN_DIR=/opt/rog2/bin
mkdir -p $RUN_DIR && cd $HOME_DIR
git clone https://github.com/rog2/unreal-stress-test.git
./ueserver-stress-test/scripts/common/bootstrapper.sh $RUN_DIR
