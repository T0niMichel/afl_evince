#!/usr/bin/env bash

export INPUT='/data/input'
export OUTPUT='/data/output'
export MOUNT=`pwd`
export AFL_IMAGE='tonimichel/afl_evince'
export FUZZ_TARGET='/usr/local/bin/evince'

sudo echo core >/proc/sys/kernel/core_pattern
cd /sys/devices/system/cpu
sudo echo performance | tee cpu*/cpufreq/scaling_governor
cd -
pwd
docker run -m 6g -ti --rm  \
       -e DISPLAY=$DISPLAY \
       -v /tmp/.X11-unix:/tmp/.X11-unix  \
       -v $MOUNT:/data \
       --ulimit core=-1 \
       --ulimit data=-1 \
       tonimichel/afl_evince \
       afl-fuzz -Z 0-3 -t 2000+ -m 4096 -i $INPUT  -o $OUTPUT  $FUZZ_TARGET

