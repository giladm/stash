mysqldump -u notify  -h stg.hm.db01 -p  lportal_hm > back/lportal_hm.dump
mysqldump -u notify  -h stg.hm.db01 -p  notification_hm > back/notification_hm.dump
mysqldump -u notify  -h stg.hm.db01 -p  statistics_hm > back/statistics_hm.dump
mysqldump -u notify  -h stg.hm.db01 -p  location_hm > back/location_hm.dump
mysqldump -u notify  -h stg.hm.db01 -p  quartz_hm > back/quartz_hm.dump

/opt/mongodb/bin/mongodump  -h localhost -db statistics -o ~gilad/back/statistics.mongo.dump
/opt/mongodb/bin/mongodump  -h localhost -db notification -o ~gilad/back/notification.mongo.dump
/opt/mongodb/bin/mongodump  -h localhost -db users -o ~gilad/back/users.mongo.dump
/opt/mongodb/bin/mongodump  -h localhost -db location -o ~gilad/back/location.mongo.dump
/opt/mongodb/bin/mongodump  -h localhost -db tag -o ~gilad/back/tag.mongo.dump

cp  back/lportal_hm.dump  /opt/share/gm/db/move
cp  back/notification_hm.dump  /opt/share/gm/db/move
cp  back/statistics_hm.dump  /opt/share/gm/db/move
cp  back/location_hm.dump  /opt/share/gm/db/move
cp  back/quartz_hm.dump  /opt/share/gm/db/move


cp -r back/statistics.mongo.dump/ /opt/share/gm/db/move
cp -r back/notification.mongo.dump/ /opt/share/gm/db/move
cp -r back/users.mongo.dump/ /opt/share/gm/db/move
cp -r back/location.mongo.dump/ /opt/share/gm/db/move
cp -r back/tag.mongo.dump/ /opt/share/gm/db/move

