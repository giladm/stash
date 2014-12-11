#!/bin/bash
#
# Current day and time
nowis=`date +%Y-%m-%dT%H:%M`

# A utility function to append a string to a file
function fappend {
    echo "$2">>$1;
}
# Send mail with proper content
SendMail2 ()
{
TOEMAIL="accountmanagement@xtify.com";
	#TOEMAIL="gilad@xtify.com";
        FREMAIL="$2";
        SUBJECT="Notify the following users their certificate is about to expire in 10 days:";
        MSGBODY="$1";

        TMP="/tmp/tmpfil_123"$RANDOM;
        rm -rf $TMP;
        fappend $TMP "From: $FREMAIL";
        fappend $TMP "To: $TOEMAIL";
        fappend $TMP "Reply-To: do not reply";
        fappend $TMP "Subject: $SUBJECT";
        fappend $TMP "";
        fappend $TMP "$MSGBODY";
        fappend $TMP "";
        fappend $TMP "";
        cat $TMP|/usr/sbin/sendmail -t;
        rm $TMP;
}

#
# Send email when the service is complete
# Search for the proper key words in the log file
DoSendEmail2()
{
    var=`grep 'Production Certificate for appKey' /opt/jboss/server/default/log/server.log |awk -F "|" '{print $2 "," $3}' | sort --field-separator=, -g -k 5 `
    #send email
    echo "Finish certificate check, at $nowis. Mail results from $from" >>/tmp/jboss-start.out 2>&1
#   mailMsg= `echo 'Feedback servie total keys=$var ; Export Callback total records=$var2'`
   SendMail2 "$var" $from
#echo $var
}

DoSendEmail2
