#!/bin/bash
#
# filename: 	runBatchProcess.sh
# author:	gilad
#
# This is a nightly script for Feedback, Metrics aggregator and Export callback services:
# The script:
# Start each process, check if successesful and wait for its complition before starting the next process
# at the end send an email to ops 
# stop jboss, 
# rename log file (so next server startup on the same day will have a fresh start
# shutdown the server.

# Current day and time
nowis=`date +%Y-%m-%dT%H:%M`

# A utility function to append a string to a file
function fappend {
    echo "$2">>$1;
}

# Send mail with proper content
SendMail ()
{
        TOEMAIL="gilad@xtify.com,ops@xtify.com";
#TOEMAIL="gilad@xtify.com";
        FREMAIL="$2";
        SUBJECT="Nightly process ended (Feedback, Metrics-Aggregator and Export Callback Services) ";
        MSGBODY="Auto generated email by $0 from $FREMAIL on $nowis. FeedbackService, ApplicationMetricsAggregator and ExportCallback Services were completed successfully. $1. Check /tmp/jboss-start.out on $FREMAIL server for errors. Check /opt/backup/ for file transferred to FTP";

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

# Send email when the service is complete
# Search for the proper key words in the log file
DoSendEmail()
{
    var=`grep 'End Feedback Service' /opt/jboss/server/default/log/server.log |awk -F "=" '{print $2}' `
    var2=`grep 'End Export Service' /opt/jboss/server/default/log/server.log |awk -F "=" '{print $2}' `
    #send email
    echo "Finish processing Feedback, Aggregator and ExportCallback services at $nowis. Mail results from $from" >>/tmp/jboss-start.out 2>&1
   # mailMsg= `echo 'Feedback servie total keys=$var ; Export Callback total records=$var2'`
    SendMail "Feedback servie total keys=$var ; Export MCR total records=$var2" $from

}

# Check if ExportCallbackService is complete
CheckIfExportCallbackServiceCompleted()
{
  if [[ $(grep -c 'End Export Service' /opt/jboss/server/default/log/server.log ) != 0 ]];
  then
    echo "Finish processing ExportCallback service at $nowis" >>/tmp/jboss-start.out 2>&1
    # Remove the export service from deploy folder
    rm -f /opt/jboss/server/default/deploy/ExportCallbackService.sar  >> /tmp/jboss-start.out 2>&1
    return 0
  else
    return 1
  fi
}

# Check if Aggregator is complete
CheckIfAggregatorServiceCompleted()
{
  if [[ $(grep -c 'ApplicationMetricsAggregator Done' /opt/jboss/server/default/log/server.log ) != 0 ]];
  then
    echo "Finish processing Aggregator service at $nowis" >>/tmp/jboss-start.out 2>&1
    # Remove the aggregator service from deploy folder
    rm -f /opt/jboss/server/default/deploy/ApplicationMetricsAggregator.sar  >> /tmp/jboss-start.out 2>&1
    return 0
  else
    return 1
  fi
}

# check the log file for feedback complete. return 0 if success
CheckIfFeddbackServiceCompleted()
{
  if [[ $(grep -c 'End Feedback Service' /opt/jboss/server/default/log/server.log ) != 0 ]];
  then
    echo "Finish processing Feedback service at $nowis" >>/tmp/jboss-start.out 2>&1

    # Remove the feedback service from deploy folder
    rm -f /opt/jboss/server/default/deploy/FeedbackService.sar  >> /tmp/jboss-start.out 2>&1

    return 0
  else
    return 1
  fi
}

# main program
SUCCESS=0
uname=`uname -a`
from=`echo "$uname" | awk -F " " '{print $2}'`
# time to wait in the 'for loop' before checking again if jboss finishes a process
wait_time=60

# 1 loop ExportCallbackService
cp -p /opt/share/master/ExportCallbackService.sar /opt/jboss/server/default/deploy  >> /tmp/jboss-start.out 2>&1
# 1st loop
for (( ; ; ))
do
    echo "Infinite loop. either ctrl-c or wait for the export service to complete"
    nowis=`date +%Y-%m-%dT%H:%M`
    CheckIfExportCallbackServiceCompleted
    if [ $? -eq $SUCCESS ]
    then
        echo "ExportCallback service success at $nowis" >> /tmp/jboss-start.out 2>&1
        break
    else
        echo "ExportCallback service is still running. Wait 10 min then check again"       
        sleep $wait_time
    fi
done

sleep 2
#source starts the script export script to ftp server
source /opt/share/scripts/batch/runExportCallbackProcess.sh

# 2 loop Feedback
#cp -p ~gilad/FeedbackService.sar /opt/jboss/server/default/deploy  >> /tmp/jboss-start.out 2>&1
cp -p /opt/share/master/FeedbackService.sar /opt/jboss/server/default/deploy  >> /tmp/jboss-start.out 2>&1
for (( ; ; ))
do
    echo "Infinite loop. either ctrl-c or wait for the feedback service to complete"
    nowis=`date +%Y-%m-%dT%H:%M`
    CheckIfFeddbackServiceCompleted
    if [ $? -eq $SUCCESS ]
    then
        echo "Feedback service success at $nowis" >> /tmp/jboss-start.out 2>&1
        break
    else
        echo "Feedback service is still running. Wait 10 min then check again"       
        sleep $wait_time
    fi
done

sleep 2
#find the expired certificates and emails them to acct managmement.
source /opt/share/scripts/batch/getExpiredCertificates.sh

# 3 loop metrics aggregation
cp -p /opt/share/master/ApplicationMetricsAggregator.sar /opt/jboss/server/default/deploy  >> /tmp/jboss-start.out 2>&1
for (( ; ; ))
do
                echo "Infinite loop. either ctrl-c or wait for Metric Aggregator service to complete"
                nowis=`date +%Y-%m-%dT%H:%M`
                CheckIfAggregatorServiceCompleted
                if [ $? -eq $SUCCESS ]
                then   
                        echo "Metrics Aggregator service completed at $nowis" >> /tmp/jboss-start.out 2>&1
                        break
                else   
                        echo "Aggregator service is still running. Wait 10 min then check again"       
                        sleep $wait_time
                fi
done

#All completed
DoSendEmail


 #stop jboss
service jboss stop
    # move the log file from the log dirctory so if starting again on same day it will not find the End token
    mv /opt/jboss/server/default/log/server.log /opt/jboss/server/default/log/server.log.$nowis  >> /tmp/jboss-start.out 2>&1


#shut down mongos
/etc/rc.d/init.d/xmongos stop

# shutting down the server
echo "Shutting server down in a minute at $nowis" >> /tmp/jboss-start.out 2>&1
echo "Really shutting down. Type: shutdown -c to cancel shutdown" 
`shutdown -h +1 ` #shutdown in one minutes. ctrl-C or shutdown -c to cancel


