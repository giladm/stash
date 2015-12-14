/*
 * Gilad Melamed
 *  find dups based on app.last.opened 'sum.alo'
 * IBM
 */
if( baseAppKeyI == '') {
        print("App key not set. Exiting");
        exit ;
}
if( dryrunI == '') {
        print("dryrun is not set default to true");
        dryrunI=true;
}

// For Production the following would be different
 dbUsersSecondary = connect ("prd.rsbdb03.ec2.xtify.com:27018/users") ;
 dbUsersSecondary.getMongo().setSlaveOk();
 dbUsersPrimary = connect ("prd.rsbdb01.ec2.xtify.com:27018/users") ;
 dbStatistics = connect ("prd.db26.ec2.xtify.com:27017/statistics") ;
 dbFeedback = connect ("prd.db29.ec2.xtify.com:27017/feedback") ;

 /* qa20 host settings
 dbUsersSecondary = connect ("localhost:27017/users") ;
 dbUsersPrimary = connect ("localhost:27017/users") ;
 dbStatistics = connect ("localhost:27017/statistics") ;
 dbFeedback = connect ("localhost:27017/feedback") ;

/* create a temp collection for deactivated devices from this script
 dbUsersPrimary.tempXidDeactivated.drop();
*/

// deactivate channel and keep xid in temp collection
var deactiveChannelAndInactiveXid = function (xidToDelete) {
                print ("Would have deactivate xid:",xidToDelete );
        if ( dryrunI =='false' )  {
                dbUsersPrimary.Channel.update({xid:xidToDelete},{$set:{act:false }},false,true);
                dbFeedback.InactiveXid.insert({
                        "_id": xidToDelete ,
                        "ak": baseAppKeyI ,
                        "rd": new Date(yy, mm, dd) ,
                        "isd": new Date(yy, mm, dd)
                });
                dbUsersPrimary.tempXidDeactivated.insert ({
                        "_id":xidToDelete
                });
           } else {
                print ("Would have deactivate xid:",xidToDelete );
           }
}
// Inner loop function
var loop1 = function (channel) {
        var str=channel.tok;
        totalGenToken++;
        if (typeof channel.sum != 'object' || channel.sum.alo == null) { // There is no alo
                groupNoAlo++;
                print("remove xid:",channel.xid," no alo");
                deactiveChannelAndInactiveXid(channel.xid);
                return;
        }
        alo = channel.sum.alo ;
        var diff =alo-channel.cre;
        //print("xid:",channel.xid," , diff:",diff/1000); // 1sec:1000
        if (diff <3600000 && diff > 0) { //5mins:300000:60Kx5; 60mins:3600K ; 1day:86,400K; 7days:604,800K
                groupAloTooClose ++ ;
                print("remove xid:",channel.xid," alo is too close to reg time:",diff/60000," minutes");
                deactiveChannelAndInactiveXid(channel.xid);
        } else {
                cumulativeLapseAppOpen +=diff ; // the elapsed time between registration and alo
                groupGenOk++ ;
        }
}
// Main loop run between dates
var mainLoop = function (edate,edateplus) {
        print ("Run query between edate:", new Date(edate), ", and",new Date(edateplus));
        dbUsersSecondary.Channel.find( { scope : baseAppKeyI, act : true, cre : { $gt : edate, $lt : edateplus }, uk : /^gen-reg-tok/ }).hint('scope_1_act_1_cre_1').forEach(loop1)
}

// drop temp collection
var alo, totalGenToken=0, groupNoAlo=0, groupAloTooClose=0, averageLapseAppOpen, cumulativeLapseAppOpen =0,groupGenOk=0;
var today = new Date();
var yy = today.getFullYear();
var mm = today.getMonth() ;
var dd = today.getDate() ;
var em, ey ;// end month, year
  if (mm ==0 ) { // Need a special case for January 
        em =11 ;
        ey = yy -1;
  } else {
        em = mm-1;
        ey = yy ;
  }

// end run date is one month prior to the currnt day
 var enddate = new Date(ey,em,dd)*1;

// When running the script on ongoing basis use bdate as: enddate -86400000*7; 
// begin run is 7 days prior to end date.  =end date - 86,400K  *7
// else use bdate as: new Date(2014,0,1)*1; //1.1.2014
 var bdate = enddate -86400000*7;
/*
 var bdate = new Date(2014,0,1)*1; // no dups before 1.1.2014
*/
 print("Start query finder for appKey=",baseAppKeyI,", from:", bdate," through:",enddate );
                mainLoop(bdate , enddate) ;
/* uncomment this loop when running the script for the first time
        // one month: (mili seconds in a day) *30 = 86,400K  *30 =2592000000 
        var bRunDate =bdate;
        // loop from begining to end, 30 days at a time
        for (i=bdate ; i<enddate ; i+= 2592000000 ) {
                mainLoop(bRunDate , bRunDate+2592000000) ;
                bRunDate += 2592000000;
        }
// end of loop through dates

*/
// update metrics
var totalDeactivated = groupNoAlo+groupAloTooClose ;
if ( dryrunI =='false' )  {
    dbStatistics.ApplicationMetricsDailyEntity.update(
        {"appKey":baseAppKeyI,"time": new Date(yy,mm,dd) } ,
        {
                $inc: { "actions.AU" : totalDeactivated }
        },
        { upsert: true } );
}
averageLapseAppOpen =cumulativeLapseAppOpen/groupGenOk;
print ("Total alo is missing:", groupNoAlo );
print ("Total alo is too close to reg time:", groupAloTooClose );
print ("Total deactivated:",totalDeactivated);
print ("Total gen token:",totalGenToken);
print ("Total gen tokens that were not deactivated:",groupGenOk);

print ("Rate of deactivated gen token to total gen tokens: %",totalDeactivated/totalGenToken*100 );

