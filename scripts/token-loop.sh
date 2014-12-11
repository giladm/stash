#!/bin/bash
# one by one, grep a token from source_file and if exists in search_file, dump the token and the xid to an output file
>token_and_xid.out

if [ $1 ]
then
    for tok in $(cut -f 1 $1); do
        #echo [$tok]
        var=`grep -m 1 $tok $2 |awk -F "," '{print $2}' `
        if [ 1 ] ; # [[ $(grep -c 'End Feedback Service' /opt/jboss/server/default/log/server.log ) != 0 ]];
        then
                echo $tok, $var >> token_and_xid.out
        fi
    done
else
  echo usage $0 source_file search_file
fi

