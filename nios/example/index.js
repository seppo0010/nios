var fs = require('fs');
fs.open('a', "r", null, function(err, fd) {
	if (err)
		alert("failed to open")
	else
		alert("was opened " + fd);
})
