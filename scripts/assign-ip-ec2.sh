#!bin/sh
# # This script assigns an Elastic IP to Instance on Reboot or Restart
# Export Java Home and EC2 Home. If you are not sure where Java is installed or EC2 tools are installed run command 'set' to find the values.
export EC2_HOME='/opt/aws/apitools/ec2';
export JAVA_HOME='/usr/lib/jvm/jre';
# Set the variables for Instance
# Region in Which instance is running
EC2_REGION='us-west-2'
# Access Key of the User
AWS_ACCESS_KEY='AXXXXXXXXXXXXXXQ'
#Secret Access Key of the user
AWS_SECRET_ACCESS_KEY='JXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXa'
#Elastic IP Which will be assigned to Instance
Elastic_IP='54.245.229.138'
#Instance ID captured through Instance meta data
InstanceID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
echo "Assigning Elastic IP to Instance"
/opt/aws/apitools/ec2/bin/ec2-associate-address -O $AWS_ACCESS_KEY -W $AWS_SECRET_ACCESS_KEY -i $InstanceID --region $EC2_REGION $Elastic_IP
