#!/usr/bin/env bash

IN=input
OUT=output
MOUNT=~/
AFL_IMAGE=tonimichel/afl_evince

FUZZ_TARGET=/usr/local/bin/evince

docker run -ti  -e DISPLAY=$DISPLAY \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -v $MOUNT:/data \
       -d --name=${FUZZ_ID}${i}\
       $AFL_IMAGE \
       afl-fuzz -i $IN -o $OUT -S ${FUZZ_ID}${i} $FUZZ_TARGET
