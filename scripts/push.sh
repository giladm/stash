# send directly to APS using token certificate and topic
# to get .pem certificate use convert-cert.sh
#
if [ $# -ne 4 ]
then
        echo usage $0 aps_content pem_certificate_file topic token 
	echo Example $0 '{"content-available":1}}' "/Users/gilad/Documents/keys/worklight/apns-dev-cert.pem" "gm.worklight.multi" bf8e37ad287de32f3910fafd0dd9f8e69a11827dda430c14d05892d2f337ca0f
	exit 
fi

content=$1
cert=$2
topic=$3
token=$4

curl -v -d $content --cert $cert:"" -H "apns-topic:"$topic --http2 https://api.development.push.apple.com/3/device/$token

