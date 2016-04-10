#!/bin/bash
#
# Gilad 
# run java script with this app key
#

if [ $1 ]
then   
        baseAppKeyI="$1"
else
  echo usage $0 appKey javascript.js dryrun=true/false 
  exit 1;
fi

if [[ $2 ]] && [[ -r $2 ]]
then
        javascriptFile="$2"
else
  echo File $2 does not exist
  echo usage $0 appKey javascript.js dryrun=true/false 
  exit 2;
fi

if [ $3 ]
then    
        dryrunI="$3"
else    
        dryrunI=true
fi      
        
echo Start `date`
             
varEvals="var baseAppKeyI='"$baseAppKeyI"', dryrunI='"$dryrunI"'"
echo $varEvals 
        
/opt/mongodb/bin/mongo --eval "$varEvals"  ./$javascriptFile

