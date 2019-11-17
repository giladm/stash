# send directly to APS using token certificate and topic
# to get .pem certificate use convert-cert.sh
# send to prod or sand (i.e: send to production or sandbox server)
#
server=$1
cert=$2
topic=$3
token=$4
if [ $# -ne 4 ]
then
	echo 
        echo usage $0 prod/sand pem_certificate_file topic token 
	echo 
	echo server[$1] cert[$2] topic[$3] token[$4]
	echo Example $0 sand "/Users/gilad/Documents/keys/worklight/apns-dev-cert.pem" "gm.worklight.multi" bf8e37ad287de32f3910fafd0dd9f8e69a11827dda430c14d05892d2f337ca0f
	echo or $0 sand gilad-testsp-dev.pem gilad.testsp 1d1e782590e1464a749d7d7bb0d7ed37d4e0135cb309f468ea0c8ca2c06c6dfd
	echo 
	exit 
fi


if [ "$server" == "sand" ] 
then
	echo Sending to sandbox
	sleep 2
    	curl -v \
        	-d '{"aps":{"alert":"test apns sandbox from http2"}}' \
        	-H "apns-topic: $topic" \
        	-H "apns-expiration: 1" \
        	-H "apns-priority: 10" \
        	--http2 \
        	--cert $cert:"" \
        	https://api.development.push.apple.com/3/device/$token
	exit 0
fi
if [ "$server" == "prod" ] 
then
	echo Sending to $token in Production
	sleep 2
        # -d '{"aps":{"alert":"curl test3 to apns","sound":"default","badge":3}}' \
    curl -v \
        -d '{"aps":{"alert":"test apns from http2"}}' \
        -H "apns-topic: $topic" \
        -H "apns-expiration: 1" \
        -H "apns-priority: 10" \
        --http2 \
        --cert $cert:"" \
        https://api.push.apple.com/3/device/$token
else
	echo Sandbox or Production ?
fi
