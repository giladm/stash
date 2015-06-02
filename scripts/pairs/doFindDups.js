/*
 * Gilad Melamed
 * IBM
 */
if( baseDateI == '') {
        print("Date not set. Exiting");
        exit ;
}
var baseAppKeyI ='2f601cfe-ac5d-41c9-a082-0bb675012032';
if( baseAppKeyI == '') {
        print("App key not set. Exiting");
        exit ;
}
print("start query finder for appKey=",baseAppKeyI," for date:",baseDateI);
db = connect ("localhost:27017/users") ;
// script to evaluate id base on timestamp
db.system.js.save(
   {   
        _id : "objectIdWithTimestamp",
        value : function (timestamp) {
        if (typeof(timestamp) == 'string') {
                timestamp = new Date(timestamp);
        }
        // Convert date object to hex seconds since Unix epoch
        var hexSeconds = Math.floor(timestamp/1000).toString(16);
        // Create an ObjectId with that hex timestamp
        var constructedObjectId = ObjectId(hexSeconds + "0000000000000000");
        return constructedObjectId
        }
   }
);
db.loadServerScripts();
// main function
remap = function (x) {
//      print("xid:",x.xid," ",x.uk);
//      print("Reg=", x.reg , "Vsdk=",x.vSDK,"Vos=",x.vOS,"Off=",x.off,"Crr=",x.crr);
        newReg=  (new Date(x.reg)).getTime() ;
        if ( /^gen-reg-tok.*/.test(x.uk) ) {
                lastXid=x.xid ;
                if (lastReg == newReg && lastVsdk ==x.vSDK && lastVos ==x.vOS && lastOff==x.off && lastCrr==x.crr ) {
                        match ++ ;
                //db.dups_2reg.insert ({"xid":x.xid});
                        totalDups  ++ ;
                        print ("Deactivate xid:",x.xid, ", match:",match);
                }
                else { // generated token and no match
                        lastReg = x.reg;
                        lastVsdk =x.vSDK;
                        lastVos =x.vOS ;
                        lastOff=x.off ;
                        lastCrr=x.crr ;
                        match =0;
                }
        }
        else { // real token
                if (lastReg == newReg && lastVsdk ==x.vSDK && lastVos ==x.vOS && lastOff==x.off && lastCrr==x.crr ) {
                        match ++ ;
        //db.dups_2reg.insert ({"xid":lastXid});
                        totalDups  ++ ;
                        print ("Deactivate xid:",lastXid, ", match:",match);
                }
                lastReg = (new Date(x.reg)).getTime() ;
                lastVsdk =x.vSDK;
                lastVos =x.vOS ;
                lastOff=x.off ;
                lastCrr=x.crr ;
        }
}
// drop temp collection
//      db.dups_2reg.drop();
var match=0; // 0:different something, 1:reg,vSDK,vOS,off,crr matching, 2:
var lastReg;
var lastVsdk ="";
var lastVos="";
var lastOff="";
var lastCrr="";
var lastXid="";
var totalDups=0;
var newReg ;
db.Channel.find({"scope" : baseAppKeyI, act:true, _id: { $gt: objectIdWithTimestamp( baseDateI)}} ).sort({cre:1}).forEach(remap);

print ("Total totalDups:", totalDups);
