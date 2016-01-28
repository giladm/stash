#!/bin/bash
#
# 
# author: njances
# Based on original script runBatchProcess.sh by gilad
#
# Script does:
# stops jboss if running
# removes deloy files
# starts jboss
# deploys files in order (ExportCalback, FeedbackService, then ApplicationMetricsAggregator)
# logs completion of each step
# removes deploy files
# stops jboss
# monitoring will be done on the /opt/jboss/server/default/log/server.log

export PATH="$PATH:/sbin"

# Current day and time
nowis=`date +%Y-%m-%dT%H:%M`
logdone=/opt/log/feedback.done
truncate -s 0 $logdone

# A utility function to append a string to a file
function fappend {
    echo "$2">>$1;
}
# Send mail with proper content
SendMail ()
{
	TOEMAIL="njances@us.ibm.com,dbtran@us.ibm.com,giladm@il.ibm.com,hhtsoi@us.ibm.com,vcramrak@us.ibm.com";
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
    echo "Finish processing Feedback, Aggregator and ExportCallback services at $nowis. Mail results from $from" 
   # mailMsg= `echo 'Feedback servie total keys=$var ; Export Callback total records=$var2'`
    SendMail "Feedback servie total keys=$var ; Export MCR total records=$var2" $from

}

# Check if ExportCallbackService is complete
CheckIfExportCallbackServiceCompleted()
{
  if [[ $(grep -c 'End Export Service' /opt/jboss/server/default/log/server.log ) != 0 ]];
  then
    echo "Finish processing ExportCallbackService at " `date`
    # Remove the export service from deploy folder
    rm -f /opt/jboss/server/default/deploy/ExportCallbackService.sar  
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
    echo "Finish processing ApplicationMetricsAggregator service at " `date`
    # Remove the aggregator service from deploy folder
    rm -f /opt/jboss/server/default/deploy/ApplicationMetricsAggregator.sar  
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
    echo "Finish processing FeedbackService at " `date`

    # Remove the feedback service from deploy folder
    rm -f /opt/jboss/server/default/deploy/FeedbackService.sar  

    return 0
  else
    return 1
  fi
}

stopJboss()
{
    echo "Stopping Jboss"
    if [[ $( ps -ef | grep jboss | grep -vc grep ) != 0 ]];
    then
        service jboss stop
        echo "Jboss stopped"
    else
        echo "Jboss not running"
    fi
}

startJboss()
{
    echo "Startiing Jboss"
    if [[ $( ps -ef | grep jboss | grep -vc grep ) != 0 ]];
    then
        echo "Jboss already running"
    else
        service jboss start
        sleep 40
        # waiting until it is started up fully
        echo "Jboss started"
    fi
}


# main program
SUCCESS=0
uname=`uname -a`
from=`echo "$uname" | awk -F " " '{print $2}'`
# time to wait in the 'for loop' before checking again if jboss finishes a process
wait_time=600


deploydir=/opt/jboss/server/default/deploy
masterdir=/opt/share/master

feedbackservice=FeedbackService.sar
exportcallbackservice=ExportCallbackService.sar
applicationmetricsaggregator=ApplicationMetricsAggregator.sar

stopJboss

echo "Clearing deployed files"
for file in $feedbackservice $exportcallbackservice $applicationmetricsaggregator;
do
    rm -f $deploydir/$file
done

startJboss

# 1 loop ExportCallbackService
echo "Working on Export Callback Service"
cp -p $masterdir/$exportcallbackservice $deploydir
chown jboss.jboss $deploydir/$exportcallbackservice
touch $deploydir/$exportcallbackservice

# 1st loop
echo "Waiting for ExportCallback service to complete"
sleep 60
for (( ; ; ))
do
    nowis=`date +%Y-%m-%dT%H:%M`
    CheckIfExportCallbackServiceCompleted
    if [ $? -eq $SUCCESS ]
    then
        echo "ExportCallback service success at $nowis" 
        break
    else
        echo "ExportCallback service is still running. " `date`      
        sleep $wait_time
    fi
done

sleep 2
#source starts the script export script to ftp server
source /opt/share/scripts/batch/runExportCallbackProcess.sh

# 2 loop Feedback
cp -p $masterdir/$feedbackservice $deploydir  
chown jboss.jboss $deploydir/$feedbackservice
touch $deploydir/$feedbackservice

echo "Waiting for Feedback Service to complete"
sleep 60
for (( ; ; ))
do
    nowis=`date +%Y-%m-%dT%H:%M`
    CheckIfFeddbackServiceCompleted
    if [ $? -eq $SUCCESS ]
    then
        echo "Feedback service success at $nowis" 
        break
    else
        echo "Feedback service is still running. " `date`
        sleep $wait_time
    fi
done

sleep 2

# old method made a ticket for CS
#find the expired certificates and emails them to acct managmement.
# echo "running getExpiredCertificates.sh"
# source /opt/share/scripts/batch/getExpiredCertificates.sh
echo "running /opt/share/scripts/batch/expired_certificates.py"
/opt/share/scripts/batch/expired_certificates.py

echo "Copying out Application Metrics Aggregator code"

# 3 loop metrics aggregation
cp -p $masterdir/$applicationmetricsaggregator $deploydir  
chown jboss.jboss $deploydir/$applicationmetricsaggregator
touch $deploydir/$applicationmetricsaggregator

echo "Waiting for Application Metrics Aggregator to complete"
sleep 60
for (( ; ; ))
do
                nowis=`date +%Y-%m-%dT%H:%M`
                CheckIfAggregatorServiceCompleted
                if [ $? -eq $SUCCESS ]
                then   
                        echo "Metrics Aggregator service completed at $nowis" 
                        break
                else   
                        echo "Aggregator service is still running. " `date`
                        sleep $wait_time
                fi
done

#All completed
DoSendEmail


 #stop jboss
stopJboss
    # move the log file from the log dirctory so if starting again on same day it will not find the End token
    mv /opt/jboss/server/default/log/server.log /opt/jboss/server/default/log/server.log.$nowis  
    # just remove file since it takes up too much space when run in DEBUG mode
    # rm /opt/jboss/server/default/log/server.log.$nowis

# clean up jboss files /opt/jboss/server/default/log older than 2 days
/bin/find /opt/jboss/server/default/log -mtime +2 | xargs rm -f

date > $logdone
echo "updated by $0" >> $logdone
