screen -dmS "gilad" ;
screen -S "gilad" -X screen; screen -S "gilad" -p 0 -X title "home"
screen -S "gilad" -X screen; screen -S "gilad" -p 1 -X title "mce"
screen -S "gilad" -X screen; screen -S "gilad" -p 2 -X title "v2.x"
screen -S "gilad" -X screen; screen -S "gilad" -p 3 -X title "xcode"
screen -S "gilad" -X screen; screen -S "gilad" -p 4 -X title "push"
screen -S "gilad" -X screen; screen -S "gilad" -p 5 -X title "db"


#cd /Users/gilad/Library/Developer/Xcode/DerivedData #xcode build folder

#cd /Users/gilad/workspace/any-java-projects/xwebservice/push

# ssh -L 3306:localhost:3306 devjbx01 ssh -L 3306:localhost:3306 -N xtify-dev@prd.db25.ec2.xtify.com
# ssh -L 3306:localhost:3306 devjbx01 ssh -L 3306:localhost:3306 -N xtify-dev@qa20mysql01
# ssh -L 27017:localhost:27017 devjbx01 ssh -L 27017:localhost:27017 -N xtify-dev@qa20mongodb01
# ssh -L 3306:localhost:3306 devjbx01 ssh -L 3306:localhost:3306 -N xtify-dev@p20usmy01

#bluemix i
# export VCAP_APP_PORT=5000 ; python /Users/gilad/workspace/bluemix/sync/salestool/server.py # start local web server on port 5000
# mongod --dbpath /Users/gilad/Documents/data/db/ # run mongodb on local
#cd /Users/gilad/workspace/bluemix/sync/salestool
# cf logs watsonxtify # check runtime web log

#cd /Users/gilad/Documents/Customers/ICICI/iphone1213/Sample-iMobile/native_Production/wls62Wls62Iphone.xcodeproj
