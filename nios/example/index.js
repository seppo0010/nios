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

	
	var dgram = require('dgram');
	var message = new Buffer("Some bytes");
	var client = dgram.createSocket("udp4");
	client.send(message, 0, message.length, 41234, "localhost", function(err, bytes) {
				client.close();
				});
}catch(e) {
	alert(e);
}