#!/bin/sh
#
# The script: 	runExportCallbackProcess.sh
# author: 	gilad
#
# Based on the current day, the script search for the file exported file in the /tmp/ folder
# Encrypt the file
# Export the file to ftp server.  
#
nowis=`date +%Y-%m-%dT%H:%M`
todayis=`date -d '1 day ago' +%Y%m%d`
base_name="xf_gf_export_"
extension=".txt"
file_folder="/tmp/"
file_name="$base_name$todayis$extension"
ftp_batch_file="ftp_batch_file.ftp"
outfile="$file_name.gpg"
ftp_user="b_xtify_01@fts.fico.net"
ftp_put_folder="/internal/ToFICO"
SSHPASS="wg%CI8rw"

if [ ! -f $file_folder$file_name ];
then   
        echo "No Callback file today ($todayis). No $file_folder$file_name to export."
#       exit 0 ;
else
  	echo "Starting at $nowis. Encrypting $file_name in $file_folder"

	head  $file_folder$file_name
	#gpg --trust-model always --batch --yes --encrypt   --recipient 'ML_FTS_Support@fico.com' file_before_encryption.txt
	#--armor -a     Create ASCII armored output.  The default is to create the binary OpenPGP format.
	# --decrypt -d     Decrypt  the  file given on the command line (or STDIN if 

	# Encrypt the export file using gpg
	gpg --trust-model always --batch --yes --output $file_folder$outfile --encrypt  --recipient 'ML_FTS_Support@fico.com' $file_folder$file_name

	echo "Creating $ftp_batch_file"
	#
	# Create an batch that will be executed by sftp. The file looks like this
	# Use sshpass tool
	# pwd
	# ls -la
	# cd /internal/ToFICO/xtify use xtify folder for testing only
	# put file
	# ls -la
	# bye
	
	cd $file_folder
	echo cd $ftp_put_folder         >  $ftp_batch_file
	echo ls -la                     >> $ftp_batch_file
	echo put $file_folder$outfile $outfile  >> $ftp_batch_file
	echo ls  -la                    >> $ftp_batch_file
	echo bye                        >> $ftp_batch_file
	
	/usr/local/bin/sshpass -p $SSHPASS sftp -oBatchMode=no -b - $ftp_user< $file_folder$ftp_batch_file > /tmp/$ftp_batch_file.log
	echo "ftp log file" >> /tmp/jboss-start.out 2>&1
	cat /tmp/$ftp_batch_file.log  >>/tmp/jboss-start.out 2>&1
	
	#create a backup for the file sent
	cp $file_folder$outfile /opt/backup/ >>/tmp/jboss-start.out 2>&1


fi
