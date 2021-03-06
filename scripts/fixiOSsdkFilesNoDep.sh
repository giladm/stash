#!/bin/bash
#
# command to set up links for iOS SDK
if [ $1 ]
then
	source="$1"
else
	echo usage $0 folder to copy form
	echo example: $0 /Users/gilad/Library/Developer/Xcode/DerivedData/XtifyPush-xxx/Build/Products/Debug-iphoneos/XtifyPush.embeddedframework 
	exit ;
fi
cd $source/XtifyPushNoDependencies.framework
echo Before: `ls -l $1/XtifyPushNoDependencies.framework/Versions`
ln -s Versions/Current/XtifyPushNoDependencies XtifyPushNoDependencies
ln -s Versions/Current/Resources Resources
cd Versions
ln -s A Current 
echo After: `ls -l $1/XtifyPushNoDependencies.framework/Versions`
