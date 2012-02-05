var fs = require('fs');
fs.open('a', "r", null, function() {
		alert("was opened");
})
