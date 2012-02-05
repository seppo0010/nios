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
exports.rename = function(source, target, callback) {
	Nios_call("Nios_fs", "rename", [source, target], callback);
}
exports.truncate = function(fd, len, callback) {
	Nios_call("Nios_fs", "truncate", [fd, len], callback);
}
exports.chown = function(path, uid, gid, callback) {
	Nios_call("Nios_fs", "chown", [path, uid, gid], callback);
}
exports.lchown = function(path, uid, gid, callback) {
	Nios_call("Nios_fs", "lchown", [path, uid, gid], callback);
}
exports.fchown = function(fd, uid, gid, callback) {
	Nios_call("Nios_fs", "fchown", [fd, uid, gid], callback);
}
exports.chmod = function(path, mode, callback) {
	Nios_call("Nios_fs", "chmod", [path, mode], callback);
}
exports.lchmod = function(path, mode, callback) {
	Nios_call("Nios_fs", "lchmod", [path, mode], callback);
}
exports.fchmod = function(fd, mode, callback) {
	Nios_call("Nios_fs", "fchmod", [fd, mode], callback);
}
exports.stat = function(path, callback) {
	Nios_call("Nios_fs", "stat", [path], callback);
}
exports.lstat = function(path, callback) {
	Nios_call("Nios_fs", "lstat", [path], callback);
}
exports.fstat = function(path, callback) {
	Nios_call("Nios_fs", "fstat", [fd], callback);
}