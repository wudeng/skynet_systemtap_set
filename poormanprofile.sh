#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "$0 PID OUTPU_FILE"
    exit
fi

nsamples=100
sleeptime=0
#pid=$(pidof lua)
pid=$1
output=$2
thread=${3:-all}

for x in $(seq 1 $nsamples)
do
    gdb -ex "set pagination 0" -ex "thread apply ${thread} bt" -batch -p $pid
    sleep $sleeptime
done | awk 'BEGIN { s = ""; }
/^Thread/ { print s; s = ""; }
/^\#/ { if ($3 == "in") { f = $4"@"$NF } else {f = $2"@"$NF } if (s != "" ) { s = f ";" s} else { s = f } }
END { print s }' | \
    sort | uniq -c | sort -r -n -k 1,1 | awk '{printf("%s\t%s\n",$2,$1)}' > $output
