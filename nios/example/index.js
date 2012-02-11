/*
var fs = require('fs');
fs.watchFile('b', { timeout: 10 }, function(curr, prev) {
	fs.readFile('b', 'utf8', function (err, data) {
		alert(data);
	});
	console.log(curr.mtime.getTime() - prev.mtime.getTime());
});
*/
/*
	var net = require('net');
	
	var server = net.createServer(function (socket) {
		socket.addListener("connect", function () {
			socket.write('username: ');
			socket.on('data',function(data){
				var username = data.toString().replace('\n','');
				socket.write('password: ');
				socket.on('data',function(data){
					var password = data.toString().replace('\n','');
					// verify authentication here
					// Do more stuff
				});
			});
		});
	});
	
	server.listen('8000');
*/
try {
	Nios_call("Nios", "ping", [], function(p) { console.log(p) }, true);
}catch(e) {
	alert(e);
}