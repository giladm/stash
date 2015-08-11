#!/bin/bash
#
# Gilad 
# run java script with this app key
#

if [ $1 ]
then   
        baseAppKeyI="$1"
else
  echo usage $0 appKey javascript.js
  exit ;
fi

if [ $2 ]
then   
        javascriptFile="$2"
else
  echo usage $0 appKey javascript_file.js
  exit ;
fi

echo Start `date`

baseAppKeyI_eval="var baseAppKeyI='"$baseAppKeyI"'"

/opt/mongodb/bin/mongo --eval "$baseAppKeyI_eval"  ./$javascriptFile

