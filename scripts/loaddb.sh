/opt/mongodb/bin/mongorestore   -h stg.hm.app01.ec2.xtify.com -d statistics     /opt/share/gm/db/move/statistics 
/opt/mongodb/bin/mongorestore   -h stg.hm.app01.ec2.xtify.com -d notification   /opt/share/gm/db/move/notification 
/opt/mongodb/bin/mongorestore   -h stg.hm.app01.ec2.xtify.com -d users           /opt/share/gm/db/move/users
/opt/mongodb/bin/mongorestore   -h stg.hm.app01.ec2.xtify.com -d location /opt/share/gm/db/move/location 
/opt/mongodb/bin/mongorestore   -h stg.hm.app01.ec2.xtify.com -d tag             /opt/share/gm/db/move/tag

mysql -u notify -p -e "source /opt/share/gm/db/move/lportal_hm.dump" lportal_hm
mysql -u notify -p -e "source /opt/share/gm/db/move/notification_hm.dump" notification_hm
mysql -u notify -p -e "source /opt/share/gm/db/move/statistics_hm.dump" statistics_hm
mysql -u notify -p -e "source /opt/share/gm/db/move/location_hm.dump" location_hm
mysql -u notify -p -e "source /opt/share/gm/db/move/quartz_hm.dump" quartz_hm

