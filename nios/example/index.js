var fs = require('fs');
fs.watchFile('b', { timeout: 10 }, function(curr, prev) {
	fs.readFile('b', 'utf8', function (err, data) {
		alert(data);
	});
	console.log(curr.mtime.getTime() - prev.mtime.getTime());
})
