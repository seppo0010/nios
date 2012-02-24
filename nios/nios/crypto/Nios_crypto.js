function Hash(algorithm) {
	this._algorithm = algorithm;
}

Hash.prototype.update = function (data, input_encoding) {
	this._data = data;
	this._input_encoding = input_encoding;
}

Hash.prototype.digest = function (encoding) {
	var ret = '';
	Nios_call("Nios_crypto", "digest", [this._algorithm, this._data, this._input_encoding, encoding], function (_ret) { ret = _ret; }, true);
	this._algorithm = this._data = this._input_encoding = null; // node.js doc says the object becames useless; it may be a security measure?
	return ret;
}

exports.createHash = function (algorithm) {
	return new Hash(algorithm)
}

