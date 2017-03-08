var fun = function (vsdk,vos) 
{
	if (version[vsdk] == null ) {
		version[vsdk] =[];
	}
	if (version[vsdk][vos] == null ) {
		version[vsdk][vos] = 1;
	} else {
		version[vsdk][vos] ++ ;
	}
}

var version =[];
var vsdk='2.9',vos='8.1';
for (var i=0 ; i < 4 ; i++ ) {
	fun(vsdk,vos);
	if ( i == 0 ) {
		vsdk ='2.8';
	}
	if ( i == 1 ) {
		vsdk ='2.7';
		vos = '8.0'
	}
}

console.log('v:',version);
	
