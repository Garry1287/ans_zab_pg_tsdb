#!/bin/bash

_HOSTS=$1
_C=$2
_TOS=$3
_TS=$4
outfile=$5

fping -qc$_C -O$_TOS -f $_HOSTS >result$(basename ${_HOSTS})_${_TOS} 2>&1

#get loss исправлен SED !!!!!
awk '{print $1"/"$5}' result$(basename ${_HOSTS})_${_TOS} | awk -F/ '{print $1,"loss"t,$4}' ts=$_TS t=$_TOS | sed 's/%,*//g' >> $outfile

#get min 
awk '{ if ( $8 == "" ) {print $1"/0/0/0"} else {print $1"/"$8}}' result$(basename ${_HOSTS})_${_TOS} | awk -F/ '{print $1,"min"t,$2}' ts=$_TS t=$_TOS >> $outfile

#get avg 
awk '{ if ( $8 == "" ) {print $1"/0/0/0"} else {print $1"/"$8}}' result$(basename ${_HOSTS})_${_TOS} | awk -F/ '{print $1,"avg"t,$3}' ts=$_TS t=$_TOS >> $outfile

#get max 
awk '{ if ( $8 == "" ) {print $1"/0/0/0"} else {print $1"/"$8}}' result$(basename ${_HOSTS})_${_TOS} | awk -F/ '{print $1,"max"t,$4}' ts=$_TS t=$_TOS >> $outfile

