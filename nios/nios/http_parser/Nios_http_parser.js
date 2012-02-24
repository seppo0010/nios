exports.HTTPParser = function (type) {
	this.type = type;
}

exports.HTTPParser.REQUEST = 0
exports.HTTPParser.RESPONSE = 1

exports.HTTPParser.prototype.execute = function (d, start, length) {
	Nios_call("Nios_http_parser", "execute", [ this.type, buffer_to_string(d), start, length ], this.finish.bind(this), true);
	// TODO: doing this sync because of a "race condition".
	// It seems like the http.ondata is being called and
	// expect to have parser.incoming already with the data
	// after calling parser.execute
}

exports.HTTPParser.prototype.finish = function (params) {
	var messages = params[0];
	for (var i = 0; i < messages.length; i++) {
		var event = messages[i][0];
		if (this[event]) {
			this[event].apply(this, messages[i].length >= 2 ? messages[i][1] : null);
		}
	}
}

exports.HTTPParser.prototype.reinitialize = function () {
	
}