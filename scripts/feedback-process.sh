!/bin/bash
#
# Use with caution. Server will shutdown
#
# The script checks if the Feedback service was completed, and if so:
# send email 
# stop jboss, 
# move the log file 
# and shutdown the server.

# current day and time
nowis=`date +%Y-%m-%dT%H:%M`

function fappend {
    echo "$2">>$1;
}

SendMail ()
{
        TOEMAIL="gilad@xtify.com";
        FREMAIL="$2";
        SUBJECT="Feedback Service end of process-auto generated by $FREMAIL on $nowis";
        MSGBODY="This is an auto email message test: $1";

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

# check the log file. return 0 if success

heckIfServiceCompleted()
{
  var=`grep 'End Feedback Service' /opt/jboss/server/default/log/server.log |awk -F "=" '{print $2}' `
  if [[ $(grep -c 'End Feedback Service' /opt/jboss/server/default/log/server.log ) != 0 ]];
  then
    #send email
    echo "Finish processing Feedback service at $nowis. Mail results from $from" >>/tmp/jboss-start.out 2>&1
    SendMail "Total keys=$var" $from

    # run the service only once, then move the sar file from the deploy dirctory
    mv /opt/jboss/server/default/deploy/FeedbackService.sar /opt/jboss/server/default/  >> /tmp/jboss-start.out 2>&1

    # move the log file from the log dirctory so if starting again on same day it will not find the End token
    mv /opt/jboss/server/default/log/server.log /opt/jboss/server/default/log/server.log.$nowis  >> /tmp/jboss-start.out 2>&1

    return 0

  else
    return 1
  fi
}

# main program
SUCCESS=0
uname=`uname -a`
from=`echo "$uname" | awk -F " " '{print $2}'`

# Start Feedback
mv /opt/jboss/server/default/FeedbackService.sar /opt/jboss/server/default/deploy  >> /tmp/jboss-start.out 2>&1

# main loop
for (( ; ; ))
do
    echo "Infinite loop. either ctrl-c or wait for the feedback service to complete"
    nowis=`date +%Y-%m-%dT%H:%M`
    CheckIfServiceCompleted
    if [ $? -eq $SUCCESS ]
    then
        echo "success at $nowis" >> /tmp/jboss-start.out 2>&1
         #stop jboss
        service jboss stop

        # shutting down the server
        echo "Shutting server down in a minute at $nowis" >> /tmp/jboss-start.out 2>&1
        echo "Really shutting down. To stop enter: shutdown -c" 
        `shutdown -h +1 ` #shutdown in one minutes. ctrl-C or shutdown -c to cancel
        break
    else
        echo "Feedback service is still running. Wait 10 min then check again"       
        sleep 600
    fi
done

