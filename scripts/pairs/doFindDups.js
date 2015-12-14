/*
 * Gilad Melamed
 * IBM
 */
if( baseAppKeyI == '') {
        print("App key not set. Exiting");
        exit ;
}
// when dryrun is false the script actually update the database. The default setting is dryrun == true
if( dryrunI == '') {
        print("dryrun is not set default to true");
        dryrunI=true;
}

print("start query finder for appKey=",baseAppKeyI,", dryrun=",dryrunI);
// For Production the following would be different
 db1 = connect ("localhost:27017/users") ;
 db2 = connect ("localhost:27017/statistics") ;
 db3 = connect ("localhost:27017/feedback") ;

// script to evaluate id base on timestamp
var objectIdFromDate = function (date) {
        return Math.floor((new Date(date)).getTime() / 1000).toString(16) + "0000000000000000";
};

var dateFromObjectId = function (objectId) {
        var str = objectId.toString().substring(0, 8) ;
        return new Date(parseInt(str, 16) * 1000);
};
var objectIdWithTimestamp = function (timestamp)   {
        if (typeof(timestamp) == 'string') {
                timestamp = new Date(timestamp);
        }
        // Convert date object to hex seconds since Unix epoch
        var hexSeconds = Math.floor(timestamp/1000).toString(16);
        // Create an ObjectId with that hex timestamp
        var constructedObjectId = ObjectId(hexSeconds + "0000000000000000");
        return constructedObjectId
} ;
// deactivate channel
updateCollections = function (y) {
        if ( dryrunI =='false' )  {
                id = y.valueOf();
                db3.InactiveXid.insert({
                        "_id":ObjectId( id ),
                        "ak": baseAppKeyI ,
                        "rd": new Date(yy, mm, dd) ,
                        "isd": new Date(yy, mm, dd)
                });
                db1.Channel.update({xid:ObjectId(id)},{$set:{act:false }},false,true);
        }
}
// Inner loop function
loop2 = function (x) {
        //print("loop2: _id:",x._id,"xid:",x.xid," ",globalNewDevice);
        if (globalNewDevice ) {
                globalNewDevice = false ;
                lastUk = x.uk;
                lastXid=x.xid ;
                lastCre = x.cre;
                lastVsdk =x.vSDK;
                lastVos =x.vOS ;
                lastOff=x.off ;
                lastCrr=x.crr ;
                lastMod=x.mod ;
                match =0;
                return ;
        }
        if ( /^gen-reg-tok.*/.test(x.uk) ) {
        //print("loop2: _id:",x._id,"xid:",x.xid," ",x.uk);
        //print("Cre=", x.cre , "Vsdk=",x.vSDK,"Vos=",x.vOS,"Off=",x.off,"Crr=",x.crr);
                if (lastVsdk ==x.vSDK && lastVos ==x.vOS && lastOff==x.off && lastCrr==x.crr && lastMod==x.mod ) {
                        match ++ ;
                        db1.dups_2reg.insert ({"xid":x.xid});
                        var err =db1.getLastError();
                        if (!err ) {
                                totalDups  ++ ;   // Is a duplicate key, but we don't know which one 
                                if ( dryrunI =='false' )  {
                                        updateCollections(x.xid);
                                } else {
                                        print ("Deactivate xid:",x.xid, " keep:",lastXid,", match:",match, ",time diff:",( x.cre-lastCre)/1000 );
                                }
                        }
                }
        //print("no duplicate for gen token xid:",x.xid," tok:",x.uk);
                return ;
        }
        //else  print("real token no duplicate for xid:",x.xid," tok:",x.uk);

        // token for this xid is real. Check the token for the last xid  
        if ( /^gen-reg-tok.*/.test(lastUk)) {
                //print("last token is not real. loop2: _id:",x._id,"xid:",x.xid," ",x.uk);
                //print("Cre=", x.cre , "Vsdk=",x.vSDK,"Vos=",x.vOS,"Off=",x.off,"Crr=",x.crr);
                if (lastVsdk ==x.vSDK && lastVos ==x.vOS && lastOff==x.off && lastCrr==x.crr && lastMod==x.mod ) {
                        match ++ ;
                        db1.dups_2reg.insert ({"xid":lastXid});
                        var err =db1.getLastError();
                        if (!err ) { // check for duplicate as xid can be removed more than once
                                totalDups  ++ ;
                                if ( dryrunI =='false' )  {
                                        updateCollections(lastXid);
                                } else {
                                        print ("Deactivate LAST xid:",lastXid, " keep:", x.xid," , match:",match, ",time diff:",(x.cre-lastCre)/1000 );
                                }
                        }
                        lastUk = x.uk ;
                        lastXid = x.xid ;
                }
        }
}
// for each _id, find all the devices that registered in the past so many seconds
loop1 = function(y) {
        var  baseTS = dateFromObjectId ((y._id).valueOf()).getTime();
        var   endLoopTS = baseTS+120000;
        var starLoopID = objectIdWithTimestamp(new Date(baseTS));
        var endLoopID = objectIdWithTimestamp(new Date(endLoopTS));
        //print(); print("loop1: _id:",y._id,"xid:",y.xid," start:",baseTS ," endID:",endLoopID);
        globalNewDevice = true;
        db1.Channel.find({$and :[{ "scope" : baseAppKeyI},{ act:true},{ _id :{$lt:endLoopID } },{_id: {$gt:starLoopID} } ] } ).forEach(loop2);
}
// drop temp collection
db1.dups_2reg.drop();
db1.dups_2reg.createIndex( { xid: 1 }, { unique: true } );
var match=0; // 0:initial, >0:mod,cre,vSDK,vOS,off,crr matching, 2:
var lastCre, lastUk;
var lastVsdk , lastMod ,lastVos , lastOff,  lastCrr, lastXid; var totalDups=0;
var globalNewDevice ; // global var. set to 1, at start of loop1. Used to set all 'last' parameters
var today = new Date();
var yy = today.getFullYear();
var mm = today.getMonth() ;
var dd = today.getDate() ;


//main loop
db1.Channel.find({"scope" : baseAppKeyI, act:true} ).sort({_id:1}).forEach(loop1);

// debug
//db.Channel.find({"scope" : baseAppKeyI, act:true, _id:{$gt:ObjectId("5550e868e4b096f55b0dfe6e")} } ).sort({_id:1}).limit(50).forEach(loop1);

// update metrics
if ( dryrunI =='false' )  {
    db2.ApplicationMetricsDailyEntity.update(
        {"appKey":baseAppKeyI,"time": new Date(yy,mm,dd) } ,
        {
                $inc: { "actions.AU" : totalDups }
        },
        { upsert: true } );

}
print ("Total Dups XIDs:", totalDups);

