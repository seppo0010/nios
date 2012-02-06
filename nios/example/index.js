var fs = require('fs');
fs.watchFile('b', { timeout: 10 }, function(err, stats) {
	fs.readFile('b', 'utf8', function (err, data) {
		alert(data);
	});
})
