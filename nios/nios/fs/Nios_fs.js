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
exports.link = function(srcpath, dstpath, callback) {
	Nios_call("Nios_fs", "link", [srcpath, dstpath], callback);
}
exports.symlink = function(linkdata, path, type, callback) {
	Nios_call("Nios_fs", "symlink", [linkdata, path, type], callback);
}
exports.readlink = function(path, callback) {
	Nios_call("Nios_fs", "readlink", [path], callback);
}
exports.realpath = function(path, callback) {
	Nios_call("Nios_fs", "realpath", [path], callback);
}
exports.unlink = function(path, callback) {
	Nios_call("Nios_fs", "unlink", [path], callback);
}
exports.rmdir = function(path, callback) {
	Nios_call("Nios_fs", "rmdir", [path], callback);
}
exports.mkdir = function(path, mode, callback) {
	Nios_call("Nios_fs", "mkdir", [path, mode], callback);
}
exports.readdir = function(path, callback) {
	Nios_call("Nios_fs", "readdir", [path], callback);
}
exports.close = function(fd, callback) {
	Nios_call("Nios_fs", "close", [fd], callback);
}
exports.utimes = function(path, atime, mtime, callback) {
	Nios_call("Nios_fs", "utimes", [path, atime, mtime], callback);
}
exports.futimes = function(fd, atime, mtime, callback) {
	Nios_call("Nios_fs", "futimes", [fd, atime, mtime], callback);
}
exports.fsync = function(fd, callback) {
	Nios_call("Nios_fs", "fsync", [fd], callback);
}
exports.write = function(fd, buffer, offset, length, position, callback) {
	Nios_call("Nios_fs", "write", [fd, buffer, offset, length, position], callback);
}
exports.read = function(fd, buffer, offset, length, position, callback) {
	Nios_call("Nios_fs", "read", [fd, buffer, offset, length, position], callback);
}
exports.writeFile = function(filename, data, encoding, callback) {
	Nios_call("Nios_fs", "writeFile", [filename, data, encoding], callback);
}
exports.watchFile = function(filename, options, listener) {
	Nios_call("Nios_fs", "watchFile", [filename, options, Nios_registerCallback(listener)]);
}
exports.unwatchFile = function(filename) {
	Nios_call("Nios_fs", "unwatchFile", [filename]);
}
exports.watch = function(filename, options, listener) {
	Nios_call("Nios_fs", "watch", [filename, options, Nios_registerCallback(listener)]);
}