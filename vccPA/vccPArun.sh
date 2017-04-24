#!/bin/bash

# since this script eventually runs mininet, you should run it with sudo

script=`basename $0`
#create the result dir named figures= 
figdir="./figures"
if [ ! -d "$figdir" ]; then
  mkdir -p $figdir
fi

if [ "$#" -eq 0 ]
then
	echo "run all"
	export targets="all"
else
	echo "run $@"
	export targets=$@
fi

for target in ${targets}; do
	case ${target} in
		all)
		source ./${script} 1 2 3 4
		;;
	1)
	echo "********************************************************************************"
	echo "* EXP1 Producing Fig1 21 hosts bw 1000"
	echo "********************************************************************************"
	label="fig1"
	bw=1000
    hosts=21
	./tcp_fair_RED.sh ${bw} ${label} ${hosts} RED1tab
	cp ./tcpfair/$label-RED1-${bw}mbps-c1/goodput.png ${figdir}/fig1c.png
	cp ./tcpfair/$label-RED1-${bw}mbps-c10/goodput.png ${figdir}/fig1b.png
	cp ./tcpfair/$label-RED1-${bw}mbps-c19/goodput.png ${figdir}/fig1a.png
    ;;
    2)
	echo "********************************************************************************"
	echo "* EXP2 Producing Fig2 11 hosts bw 1000"
	echo "********************************************************************************"
    label="fig2"
    bw=1000
    bw_host_low=500
    bw_host_high=1000
    ./tcp_fair_RED_ue.sh ${bw} ${bw_host_low} ${bw_host_high} ${label} RED1tab
    ;;
    
    3)
	echo "********************************************************************************"
	echo "* EXP3 Proguding Fig3 vecn and ecn 20hosts"
	echo "********************************************************************************"
    label="fig3"
	bw=1000
	clients=19
    #has noly 1 vecn flow
	./vtcp_fair.sh "virtual-ECN" ${bw} 1 1 "vecn"$(tail -1 RED1tab)
    ./vtcp_fair.sh "virtual-ECN" ${bw} 9 1 "vecn"$(tail -1 RED1tab)
	./vtcp_fair.sh "virtual-ECN" ${bw} 19 1 "vecn"$(tail -1 RED1tab)
	cp vtcpfair/vecnRED1-${bw}mbps-c1/goodput.png ${figdir}/fig3.png
	;;
    4)
	echo "********************************************************************************"
	echo "* 生成图片4 10 hosts "
	echo "********************************************************************************"
    label="fig4vecn"
    bw=1000
    bw_host_low=500
    bw_host_high=1000
    clients=9
    vtcp=1
    ./vtcp_fair_ue.sh "virtual-ECN" ${bw} ${bw_host_low} ${bw_host_high} 1 $vtcp ${label} $(tail -1 RED1tab)
    ./vtcp_fair_ue.sh "virtual-ECN" ${bw} ${bw_host_low} ${bw_host_high} 5 $vtcp ${label} $(tail -1 RED1tab)
    ./vtcp_fair_ue.sh "virtual-ECN" ${bw} ${bw_host_low} ${bw_host_high} 9 $vtcp ${label} $(tail -1 RED1tab)
    ;;
    *)
		echo "${script}: no such option" 1>&2
		exit 1
	esac
done
