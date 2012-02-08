/*
var fs = require('fs');
fs.watchFile('b', { timeout: 10 }, function(curr, prev) {
	fs.readFile('b', 'utf8', function (err, data) {
		alert(data);
	});
	console.log(curr.mtime.getTime() - prev.mtime.getTime());
});
*/
try {
	var util = require("util");
var dgram = require("dgram");
var server = dgram.createSocket("udp4");

server.on("message", function (msg, rinfo) {	
		  console.log("server got: " + msg + " from " +
					  rinfo.address + ":" + rinfo.port);
		  });

server.on("listening", function () {
		  var address = server.address();
		  console.log("server listening " +
					  address.address + ":" + address.port);
		  });
server.bind(41234);

}catch(e) {
}