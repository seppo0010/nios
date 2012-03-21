var app, io, fs, ios, text;
var sockets = [];

function start() {
	app = require('http').createServer(handler);
	io = require('socket.io').listen(app);
	ios = require('ios');
	fs = require('fs')
	
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
				  socket.on('disconnect', function () {
							for (var i = 0; i < sockets.length; i++) {
							if (sockets[i] == socket) {
							delete sockets[i];
							break;
							}
							}
							});
				  sockets.push(socket);
				  socket.emit('text', text);
				  socket.on('alert', function (data) {
							ios.alert(data); // using javascript alert blocks the execution
							});
				  });
}

function stop() {
	app.close();
}

function setText(_text) {
	text = _text;
	for (var i = 0; i < sockets.length; i++) {
		sockets[i].emit('text', text);
	}
}

Nios_registerCallback("start", start);
Nios_registerCallback("stop", stop);
Nios_registerCallback("setText", setText);