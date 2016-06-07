#!/usr/bin/env bash

#FUZZ_ID=evince
IN=/data/input
OUT=/data/output
MOUNT=.
AFL_IMAGE=tonimichel/afl_evince


FUZZ_TARGET=/usr/local/bin/evince


docker run -m 8g -ti -e DISPLAY=$DISPLAY \
       -v /tmp/.X11-unix:/tmp/.X11-unix  \
       -v .:/data \
       --ulimit core=-1 tonimichel/afl_evince \
       afl-fuzz -Z 0-3 -t 100+ms -m 2048 -i $IN  -o $OUT  $FUZZ_TARGET
