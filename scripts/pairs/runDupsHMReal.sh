#!/bin/bash
#
# Gilad 
# de dups tokens
#

#// h&m preview ios
        baseAppKeyI="4e45efdf-a1ed-4306-b34d-b91e6d7faa"

echo Start `date` AppKey $baseAppKeyI
baseAppKeyI_eval="var baseAppKeyI='"$baseAppKeyI"'"
/opt/mongodb/bin/mongo --eval "$baseAppKeyI_eval"  ./dupsHandlerHM.js
echo End `date`

# // h&m preview gcm
baseAppKeyI="cc45efdf-a1ed-4306-b34d-b91e6d7fbb"

echo Start `date` AppKey $baseAppKeyI
baseAppKeyI_eval="var baseAppKeyI='"$baseAppKeyI"'"
/opt/mongodb/bin/mongo --eval "$baseAppKeyI_eval"  ./dupsHandlerHM.js
echo End `date`

