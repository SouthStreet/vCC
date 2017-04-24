#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

if [ "$#" -lt 1 ]
then
  echo "Usage: `basename $0` bw_bneck bw_low bw _high label limit min max avpkt burst prob" 1>&2
  exit 1
fi


bw_bneck=$1; shift
bw_low=$1; shift
bw_high=$1; shift
label="$1-bn${bw_bneck}mbps"; shift
red_limit=$1; shift
red_min=$1; shift
red_max=$1; shift
red_avpkt=$1; shift
red_burst=$1; shift
red_prob=$1
key1="non-ECN"

time=12
bwnet=${bw_bneck}
#bwhost=${bw}
delay=0.25

#total hosts num 
hnum=11
#total senders num
snum=$hnum-1

warmup=5
maxtime=$[ $time+25-2 ]

iperf_port=5001

iperf=`which iperf`
qsize=1000
range="1 5 9"
for cutoff in $range; do
    dir="tcpfair/${label}-c${cutoff}"
    rm -rf $dir
    mkdir -p $dir
    python tcpfair_unequal.py --cong reno --cong1 reno --congrest reno --delay $delay -b $bwnet -Bl $bw_low -Bh $bw_high -d $dir --maxq $qsize -t $time \
    --red_limit $red_limit \
    --red_min $red_min \
    --red_max $red_max \
    --red_avpkt $red_avpkt \
    --red_burst $red_burst \
    --red_prob $red_prob \
    --ecn 0 --ecnrest 1 --cutoff $cutoff \
    --vtcp 0 --vtcprest 0 \
    --red 1 \
    --iperf $iperf -k 0 -n $hnum

    #python plot_tcpprobe.py -f $dir/cwnd.txt -o $dir/cwnd.png -p $iperf_port
    #python plot_queue.py -f $dir/q.txt --legend "tcp-ecn"  -o $dir/queue.png
    trace=$(ls -t /tmp/wireshark* | head -1)
    gzip ${trace}
    mv ${trace}.gz $dir/
    gzip $dir/cwnd.txt
    #rm -rf $dir1 $dir2
    #python plot_ping.py -f $dir/ping.txt -o $dir/rtt.png
#process and plot 
    ./process $warmup $maxtime $snum $cutoff $key1 $dir/${trace##*/}.gz
    pkill -9 iperf
    chown -R li $dir/*
done
