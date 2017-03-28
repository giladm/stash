#!/bin/bash
for i in {1..5}
do
	echo $i;
	usleep 250000;
	java -jar  ../WebserviceApi.jar -u https://sdk.api.xtify.com/2.0/users/register -f reg$i.json  -m POST -p json

done
