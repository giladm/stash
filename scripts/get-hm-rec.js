/*
 * Gilad Melamedf
 * Xtify
 * created: 10/29/12
 *
 * The script iterates over a set of conseqcutive appKey to find duplicate tokens.
 * Tokens found are inserted to a new collection hm_dups. Once completed
 * the scripts iterates over the dups, and for each finds the uk that needs to be removed
 *
 */
//var baseAppKeyI="3d96efdf-a1ed-4306-b34d-b91e6d7f6b";
var baseAppKeyI="4e45efab-b4ab-3305-a24c-b80e6d7f5b";

db = connect ("localhost:27017/users") ;
db.hm_dups.remove();
var lastUk="";
var lastCre;
var lastXid;
var lastScope;
var totalUkRemoved=0;

// Inserts tokens to a new collection of hm_dups
remap = function (x) {
       // print(x.uk+","+(x.xid),+","+x.cre,",",new Date(x.cre));
        db.hm_dups.insert({"uk":x.uk,"cre":x.cre,"xid":x.xid,"scope":x.scope});
}

// Removes the older tokens
rm_tok = function (x) {
        if (x.uk != lastUk) {
        //      print ("retruning, new uk:",x.uk, " lastUk:",lastUk);
                lastUk=x.uk;
                lastCre=x.cre;
                lastXid=x.xid;
                lastScope=x.scope;
                return;
        }
        print ("For uk:",x.uk);
        if (x.cre > lastCre) {
                print ("Removed xid:",lastXid," for scope:",lastScope);
                lastXid =x.xid;
                lastCre=x.cre;
                totalUkRemoved++;
                //db.Channel.remove({"scope":lastScope,"xid":lastXid});
        }
        else { 
                print ("Removed xid:",x.xid," for scope:",x.scope);
                totalUkRemoved++;
                //db.Channel.remove({"scope":x.scope,"xid":x.xid});
        }
}

// Main loop. Iterate over the appKeys
for (var key=0;key<9;key++)
{
        var appKey=baseAppKeyI.concat("0").concat(key);
        print(appKey);
        db.Channel.find({scope:appKey, act:true}).forEach(remap)
}
for (var key=10;key<50;key++)
{
        var appKey=baseAppKeyI.concat(key);
        print(appKey);
        db.Channel.find({scope:appKey, act:true}).forEach(remap)
}

//Iterate over the dups collection
db.hm_dups.find().sort({uk:1,cre:1}).forEach(rm_tok);
print ("Total user key removed:", totalUkRemoved);

