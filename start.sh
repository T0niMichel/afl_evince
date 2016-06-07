#!/usr/bin/env bash

#FUZZ_ID=evince
IN=/data/input
OUT=/data/output
MOUNT=.
AFL_IMAGE=tonimichel/afl_evince


FUZZ_TARGET=/usr/local/bin/evince

sudo echo core >/proc/sys/kernel/core_pattern
cd /sys/devices/system/cpu
sudo echo performance | tee cpu*/cpufreq/scaling_governor
cd -
docker run -m 2g -ti -e DISPLAY=$DISPLAY \
       -v /tmp/.X11-unix:/tmp/.X11-unix  \
       -v .:/data \
       --ulimit core=-1 tonimichel/afl_evince \
       afl-fuzz -Z 3 -t 400+ms -m 2048 -i $IN  -o $OUT  $FUZZ_TARGET

