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
limit=2000
echo Start `date` limit is $limit
for i in {0..3000000..2000}
 do
         skip=`expr  $i`
	 echo skip $skip
	skip_eval="var skip='"$skip"'"
	/opt/mongodb/bin/mongo --eval "$skip_eval"  ./dupsHandlerToken2phase.js
done
echo End `date`

