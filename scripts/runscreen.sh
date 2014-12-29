screen -dmS "gilad" ;
screen -S "gilad" -X screen; screen -S "gilad" -p 0 -X title "home"
screen -S "gilad" -X screen; screen -S "gilad" -p 1 -X title "mce"
screen -S "gilad" -X screen; screen -S "gilad" -p 2 -X title "v2.x"
screen -S "gilad" -X screen; screen -S "gilad" -p 3 -X title "xcode"
#screen -S "gilad" -X screen title "home"
#screen -S "gilad" -X screen
screen -S "gilad" -p 0 -X exec cd /Users/gilad/Library/Developer/Xcode/DerivedData #xcode build folder
#cd /Users/gilad/Library/Application Support/iPhone Simulator/5.1/Applications
#cd /Users/gilad/workspace/iphone/passbook
#scp -p   dev.app01.ec2.xtify.com:~gilad/
#cd /Users/gilad/workspace/any-java-projects/xwebservice
#cd /Users/gilad/workspace/v2.3/Xtify3.0/XtifyServices ;mvn package
#cd ~/workspace/java_projects/android-projects
#cd ~/workspace/any-java-projects/xwebservice
#cd ~/Library/MobileDevice/Provisioning\ Profiles/
#cd ~/workspace/stash/giladm # local git
