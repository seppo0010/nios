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
//			setTimeout(function() {
	var http = require("http");
	
	http.createServer(function(request, response) {
					  response.writeHead(200, {"Content-Type": "text/plain"});
					  response.write("Hello World");
					  response.end();
	}).listen(8888);
//			   }, 2000);
}catch(e) {
	alert(e);
}