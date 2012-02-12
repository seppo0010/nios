exports.HTTPParser = function (type) {
	this.type = type;
}

exports.HTTPParser.REQUEST = 0
exports.HTTPParser.RESPONSE = 1

exports.HTTPParser.prototype.execute = function (d, start, length) {
	var self = this;
	var listener = function (event, params) {
		self[event].apply(self, params);
	}
	Nios_call("Nios_http_parser", "execute", [ this.type, d, start, length, Nios_registerCallback(listener) ], this.finish);
}

exports.HTTPParser.prototype.finish = function () {
	
}

exports.HTTPParser.prototype.reinitialize = function () {
	
}