#!/bin/bash
#
# Gilad 
# de dups tokens
#

if [ $1 ]
then   
        baseAppKeyI="$1"
else
  echo usage $0 appKey
    exit ;
fi

	    echo Start `date`

	    baseAppKeyI_eval="var baseAppKeyI='"$baseAppKeyI"'"

	    /opt/mongodb/bin/mongo --eval "$baseAppKeyI_eval" ./dupsHandlerToken1phase.js

	    echo End `date`
