exports.open = function(path, flags, mode, callback) {
	Nios_call("Nios_fs", "open", [path, flags, mode], callback);
}
exports.readFile = function(filename, encoding, callback) {
	var tmp_callback = function(err, data) {
		if (encoding == null) {
			var buffer = new Buffer(data.length);
			for (var i = 0; i < data.length; i++) {
				buffer[i] = data[i];
			}
			data = buffer;
		}
		callback(err, data);
	}
	Nios_call("Nios_fs", "readFile", [filename, encoding], tmp_callback);
}