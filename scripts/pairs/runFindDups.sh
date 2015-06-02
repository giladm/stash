#!/bin/bash
#
# Gilad 
# run java script with a given appKey app key and a given date
#

if [ $1 ]
then
        baseAppKeyI="$1"
else
  echo usage $0 appKey runDate scriptFile
  exit ;
fi
baseAppKeyI_eval="var baseAppKeyI='"$baseAppKeyI"'"

if [ $2 ]
then
        baseDateI="$2"
else
  echo usage $0 appKey runDate scriptFile
  exit ;
fi
baseDateI_eval="var baseDateI='"$baseDateI"'"

/opt/mongodb/bin/mongo --eval "$baseDateI_eval" doFindDups.js
~                                                          
