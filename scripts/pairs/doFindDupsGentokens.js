/*
 * Gilad Melamed
 * IBM
 */
if( baseAppKeyI == '') {
        print("App key not set. Exiting");
        exit ;
}
print("start query finder for appKey=",baseAppKeyI);
db1 = connect ("localhost:27017/users") ;
db2 = connect ("localhost:27017/statistics") ;

// for each device with time diff less than 30 seconds
loop1 = function(y) {
        var diff =Math.abs(y.reg-y.cre);
        if (diff < 30000 ) {
                group1 ++;
                id = y.xid.valueOf();
                db1.InactiveXid.insert({
                        "_id":ObjectId( id ),
                        "ak": y.scope ,
                        "rd": new Date(yy, mm, dd) ,
                        "isd": new Date(yy, mm, dd)
                });
                db1.Channel.update({xid:ObjectId(id)},{$set:{act:false }},false,true);
        }
        else {
                group2 ++;
        }
}
var id;
var group1=0;
var group2=0;
var today = new Date();
var yy = today.getFullYear();
var mm = today.getMonth() ;
var dd = today.getDate() ;

//main loop
// find all actives device with have generated tokens
db1.Channel.find({"scope" : baseAppKeyI, act:true, tok:/^gen-reg-tok/} ).forEach(loop1);
//
// update metrics
db2.ApplicationMetricsDailyEntity.update(
        {"appKey":baseAppKeyI,"time": new Date(yy,mm,dd) } ,
        {
                $inc: { "actions.AU" : group1 }
        },
        { upsert: true } );

// print summary
print("Total inactivated device this run:",group1);
print("Total generated tokens remained active:",group2);
print("Grand total:",group2+group1);

