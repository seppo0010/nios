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
/*
	var http = require("http");
	
	http.createServer(function(request, response) {
					  response.writeHead(200, {"Content-Type": "text/plain"});
					  response.write("Hello World");
					  response.end();
	}).listen(8888);
 */
	/*
	var io = require('socket.io').listen(80);
	
	io.sockets.on('connection', function (socket) {
				  socket.emit('news', { hello: 'world' });
				  socket.on('my other event', function (data) {
							console.log(data);
							});
				  });
	 
	 */
	var app = require('http').createServer(handler, {})
	, io = require('socket.io').listen(app)
	, fs = require('fs')
	
	app.listen(8080);
	
	var __dirname = '.';
	function handler (req, res) {
		if (req.url == '/' || req.url == '') {
			fs.readFile('index.html',	
						function (err, data) {
						if (err) {
						res.writeHead(500);
						return res.end('Error loading index.html');
						}
						
						res.writeHead(200);
						res.end(data);
						});
		} else {
			res.writeHead(404);
			res.end();
		}
	}
	
	io.sockets.on('connection', function (socket) {
				  socket.emit('news', { hello: 'world' });
				  socket.on('my other event', function (data) {
							console.log(data);
							});
				  });
 /**/
//			   }, 5000);
}catch(e) {
	alert(e);
}