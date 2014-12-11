/*
 *  * Gilad Melamed
 *   * Xtify
 *    * created: 10/29/12
 *     *
 *      * The script iterates over a set of conseqcutive appKey to find duplicate tokens.
 *       * Tokens found are inserted to a new collection dups_tokens_preview. Once completed
 *        * the scripts iterates over the dups, and for each finds the uk that needs to be removed
 *         *
 *          
 */
if( baseAppKeyI == '') {
        print("App key not set. Exiting");
        exit ;
}

print("start dup finder for appKey=",baseAppKeyI);

db = connect ("localhost:27017/users") ;

// Inserts tokens to a new collection of dups_tokens_preview
remap = function (x) {
	db.dups_tokens_preview.insert({"uk":x.uk,"cre":x.cre,"xid":x.xid,"iid":x.iid});
}
rm_tok = function (x) {
        if (x.uk != lastUk) {
                lastUk=x.uk;
                lastCre=x.cre;
                lastXid=x.xid;
                return;
        }
        print ("For uk:",x.uk);
        if (x.cre > lastCre) {
                print ("Removed xid:",lastXid," for iid:",x.iid);
                db.Channel.update( { "xid" : lastXid }, { $set : { "act" : false } }, false, true );
                db.dups_tokens_to_remove.insert({"xid":lastXid});
                lastXid =x.xid;
                lastCre=x.cre;
                totalUkRemoved++;
        } else {
                print ("Removed xid:",x.xid);
                db.Channel.update( { "xid" : x.xid }, { $set : { "act" : false } }, false, true );
                db.dups_tokens_to_remove.insert({"xid":x.xid});
                totalUkRemoved++;
        }
}

// Main loop. Iterate over the appKeys
//
// // drop temp collection. all tokens are in _preview
//
db.dups_tokens_preview.drop();
// only the updated xid are in _remove

db.dups_tokens_to_remove.drop();
var lastUk="";
var lastCre;
var lastXid;
var totalUkRemoved=0;

var query = { scope: new RegExp('^' + baseAppKeyI), act: true };
//var query = { scope: baseAppKeyI, act: true };
print("start");
db.Channel.find(query).forEach(remap);

print("before index");
db.dups_tokens_preview.ensureIndex ({uk:1,cre:1});

print("before removal");
//Iterate over the dups collection
db.dups_tokens_preview.find({}).sort({uk:1,cre:1}).forEach(rm_tok);

print ("Total user key removed:", totalUkRemoved);
db.dups_tokens_to_remove.find().count();
   
