var fs = require('fs');
fs.stat('b', function(err, stats) {
	if (err)
		alert("failed to open " + err)
	else
		alert("was opened " + JSON.stringify(stats));
})
