*
 * Gilad Melamed
 * Xtify
 * created: 12/07/14
 *
 * The script iterates over an appKey to find duplicate tokens.
 * Tokens found are inserted to a new collection dups_tokens_preview. Once completed
 * call script 2
 */ 
if( baseAppKeyI == '') {
        print("App key not set. Exiting");
        exit ;
}

print("start dup finder for appKey=",baseAppKeyI);
        
db = connect ("prduspmloc07.ec2.xtify.com:27017/users") ;
        
// Inserts tokens to a new collection of dups_tokens_preview
remap = function (x) {
       // print(x.uk+","+(x.xid),+","+x.cre,",",new Date(x.cre));
        db.dups_tokens_preview.insert({"uk":x.uk,"cre":x.cre,"xid":x.xid,"iid":x.iid});
}               
                
                
// Main loop. Iterate over the appKeys
        
// drop temp collection. all tokens are in _preview
db.dups_tokens_preview.drop();
db.createCollection("dups_tokens_preview", { autoIndexId: false });
db.dups_tokens_preview.ensureIndex({uk:1});
db.dups_tokens_preview.ensureIndex({uk:1, cre:1});
                
var query = { scope: baseAppKeyI, act: true };
        
print("start"); 
db.Channel.find(query).forEach(remap);
                
print("End phase 1");
