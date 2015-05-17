#!/bin/sh
# https://github.com/borkmann/stuff/blob/master/super_netperf
echo type, proto, cores, packet size, result

run_test()
{
    TYPE=$1
    SIZE_OPT=$2
    IP=$3
    PROTO=TCP

    for CORES in 1 2 4; do
            for PACKET in 2 16 32 64 512 1024; do

RES=$(super_netperf $CORES -H $IP \
    -l 30 -t${PROTO}_${TYPE} -- $SIZE_OPT $PACKET)
        echo $TYPE, $PROTO, $CORES, $PACKET, $RES

        done
    done

}

run_test STREAM -m $1
run_test RR -r $1
run_test CRR -r $1

