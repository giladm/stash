if [ $# -ne 2 ]
then
	echo "Error in $0 - Invalid Argument Count"
	echo "Syntax: $0 p12_in_file.p12 pem_out_file.pem"
	echo "Exammple: $0 sandboxCretificate-multi.p12 apns-dev-cert.pem"
	exit 
fi
p12File=$1
pemFile=$2

openssl pkcs12 -in $p12File -out $pemFile -nodes -clcerts
