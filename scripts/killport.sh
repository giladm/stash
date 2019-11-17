#!/bin/bash
#

if [ $1 ]                                                              
then                                                                    
        port="$1"                                                 
else                                                                      
  echo usage $0 port_number_to_kill
  exit 1;                                                                   
fi                                                                           
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/apache-maven-3.2.3/bin:/home/gilad/bin:/opt/apache-maven-3.2.3/bin:/home/gilad/bin

echo killing `lsof -n  -i4TCP:$port`
lsof -n -i4TCP:$port | grep ssh | awk {'print $2'} | xargs  kill -9 
