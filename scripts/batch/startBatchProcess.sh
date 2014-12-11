#! /usr/bin/ksh
#
# The script starts app40 server from infra01 cron job
#
#
set AWS_PATH=/opt/aws
set PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/root/bin:/opt/aws/bin
export EC2_PRIVATE_KEY=/home/gilad/.ssh/pk-ec2.pem
export EC2_CERT=/home/gilad/.ssh/cert-ec2.pem
export EC2_HOME=/opt/aws/apitools/ec2
export JAVA_HOME=/usr/lib/jvm/jre

# Start prd.app40
date > /tmp/nightBatchProcess.out 2>&1
/opt/aws/bin/ec2-start-instances i-2417425d  >> /tmp/nightBatchProcess.out 2>&1
#
# wait 10 secs for the instance to start
sleep 10
/opt/aws/bin/ec2-describe-instances i-2417425d  >> /tmp/nightBatchProcess.out 2>&1
echo 'Check server for results' >> /tmp/nightBatchProcess.out 2>&1

#
# Start of server will it start invoke /etc/rc.local
# that in turns will start , and feedback service and will check every 10 mins if comleted.
# once completed, the server will shutdown

# To stop the script from running all .sar procesess you'll need to shutdown jboss (service jboss stop) in the first 2 minutes after the server starts   
