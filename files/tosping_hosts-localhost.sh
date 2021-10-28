#!/bin/bash
# fping with TOS param for zabbix
# smithy@sc.ru 20170511

## sudo fping -qc3 -i 1 -p 1 10.192.10.190 >result 2>&1 
export PATH=/var/lib/zabbix/scripts:$PATH

_C=300
_TOSs="0 104 184"
_HOSTS=/var/lib/zabbix/scripts/_hosts-localhost
_TS=$(date +%s)

if [[ ! -d /tmp/tosping ]]; then mkdir -p /tmp/tosping; fi
cd /tmp/tosping

# control running tosping.sh
if [ -f tosping$(basename ${_HOSTS}).pid ]
then
	echo "tosping is alredy running"
	exit 2
else
# running
  while true
  do
	outfile=outfile$(basename ${_HOSTS})
	echo $$ > tosping$(basename ${_HOSTS}).pid

	#control last five running, after zabbix_sender
	#touch count
	#cnt=$(cat count)

	#if (( $cnt >= 5 ))
	#then
	#	zabbix_sender -z 192.168.1.129 -T -i $outfile
	#	rm -f $outfile
	#	cnt=0
	#fi


	for _TOS in $_TOSs;
	do
		#### Run support script ####
		(suptosping.sh $_HOSTS $_C ${_TOS} $_TS ${outfile} &) 

		#### End run sup script ####

		#fping -qc$_C -i 2 -p 11 -O$_TOS $_HOSTS >result_${_TOS} 2>&1
		#fping -qc$_C -O$_TOS -f $_HOSTS >result_${_TOS} 2>&1
	
		#get loss исправлен SED !!!!!
		#awk '{print $1"/"$5}' result_${_TOS} | awk -F/ '{print $1,"loss"t,ts,$4}' ts=$_TS t=$_TOS | sed 's/%,*//g' >> $outfile
	
		#get avg 
		#awk '{ if ( $8 == "" ) {print $1"/0/0/0"} else {print $1"/"$8}}' result_${_TOS} | awk -F/ '{print $1,"avg"t,ts,$3}' ts=$_TS t=$_TOS >> $outfile

	done #_TOS
	
	while [[ $(pgrep -f "suptosping.sh $_HOSTS") ]]; 
	do 
	    sleep 1; 
	done;

	#cnt=$(($cnt+1))
	#echo $cnt > count
	#cat count
	zabbix_sender -z localhost -i $outfile 
	rm -f $outfile

  done

fi #END control running tosping.sh

rm tosping$(basename ${_HOSTS}).pid

echo 0

# loss
#cat result_0 | awk '{print $1"/"$5}' | awk -F/ '{print $1,$4}' | sed 's/%,//g'

# avg
#cat result_0 | awk '{print $1"/"$8}' | awk -F/ '{print $1,$3}'
#time cat result_$T | awk '{print $1"/"$8}' | awk -F/ '{print $1,"avg"t,ts,$3}' ts=$_TS t=$
