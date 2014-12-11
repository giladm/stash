//
////  Group by 
////
//
db = connect ("localhost:27017/users") ;
if( baseAppKeyI == '') {
        print("App key not set. Exiting");
        exit ;
}

print("start script for appKey={",baseAppKeyI,"}");
//
var tags ;
var patt ; // pattern looking for

doTheMap();

function doTheMap(){
    print("===>Running map reduce");
    var mapf = function() {
//	emit(this.vSDK, {tot: 1});
    emit(this.ons, {tot: 1});

  };


  var reducef = function(key, values) {
        var sum = 0;
        values.forEach(function(doc) {
           sum += doc.tot;
        });
        return {tot: sum};
  };

  print("Program starts");
        db.runCommand({ mapreduce : "Channel",
                map: mapf,
                reduce: reducef,
                query:{"scope":baseAppKeyI, "act" : true}, // 
                out: {replace : "vsdk_out"}
                });

}

// The results:
db.vsdk_out.find({}).forEach(printjson)
