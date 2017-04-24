#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

if [ "$#" -lt 3 ]
then
  echo "Usage: `basename $0` bw_bneck bw_low bw_high label <RED table file>" 1>&2
  exit 1
fi

bw_bneck=$1
bw_low=$2
bw_high=$3
label=$4
file=$5
if [ ! -f "$file" ]
then
	echo "file $file does not exist" 1>&2
	exit 2
fi



readarray -t lines < "$file"
for params in "${lines[@]}"; do
	# skip empty lines or lines that start with #
	if (( ${#params} == 0 )) || [[ ${params} == "#"* ]]
	then
		continue
	fi
	./tcp_fair_loop_ue.sh ${bw_bneck} ${bw_low} ${bw_high} ${label}-${params}
done 
