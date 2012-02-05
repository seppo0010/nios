var fs = require('fs');
fs.readFile('a', null,function(err, data) {
	if (err)
		alert("failed to open")
	else
		alert("was opened " + data);
})
