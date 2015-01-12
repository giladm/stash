/*
 * Gilad Melamed
 * Xtify
 * created: 12/07/14
 *
 * The script iterates over an appKey to find duplicate tokens.
 * the scripts iterates over the dups, and for each finds the uk that needs to be deactivated
 *      
 */
var limit =2100;
if( skip == ''  ) {
        print("skip or limit are not set. Exiting");
        exit ;
}

print("start dup finder for skip=",skip, " and limit=",limit);
        
db = connect ("prduspmloc07.ec2.xtify.com:27017/users") ;
        
// Removes the older tokens
rm_tok = function (x) {
        if (x.uk != lastUk) {
        //      print ("retruning, new uk:",x.uk, " lastUk:",lastUk);
                lastUk=x.uk;
                lastCre=x.cre;
                lastXid=x.xid;
                return;
        }
        print ("For uk:",x.uk);
        if (x.cre > lastCre) {
                print ("Removed xid:",lastXid," for iid:",x.iid);
         db.Channel.update( { "xid" : lastXid }, { $set : { "act" : false } }, false, true );
                lastXid =x.xid;
                lastCre=x.cre;
                totalUkRemoved++;
        } else {
                print ("Removed xid:",x.xid);
         db.Channel.update( { "xid" : x.xid }, { $set : { "act" : false } }, false, true );
                totalUkRemoved++;
        }
}

var lastUk="";
var lastCre;
var lastXid;
var totalUkRemoved=0;

print("before removal");
//Iterate over the dups collection
db.dups_tokens_preview.find({}).sort({uk:1,cre:1}).skip(skip).limit(limit).forEach(rm_tok);

print ("Total user key removed:", totalUkRemoved);

