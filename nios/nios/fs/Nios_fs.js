exports.Stats = function(data) {
	for (var k in data) {
		if (data.hasOwnProperty(k)) {
			if (k == 'mtime' || k == 'atime' || k == 'ctime')
				this[k] = new Date(parseInt(data[k]));
			else
				this[k] = data[k];
		}
	}
}

exports.open = function(path, flags, mode, callback) {
	Nios_call("Nios_fs", "open", [path, flags, mode], callback);
}
exports.readFile = function(filename, encoding, callback) {
	if (typeof encoding === 'function' && typeof callback === 'undefined') {
		callback = encoding;
		encoding = null;
	}
	var tmp_callback = function(err, data) {
		if (!err && encoding == null) {
			var str = data;
			data = string_to_buffer(data);
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
	Nios_call("Nios_fs", "stat", [path], callback ? function (err, stats) {
		stats = new exports.Stats(stats);
		callback(err, stats);
	} : null);
}
exports.lstat = function(path, callback) {
	Nios_call("Nios_fs", "lstat", [path],  callback ? function (err, stats) {
		stats = new exports.Stats(stats);
		callback(err, stats);
	} : null);
}
exports.fstat = function(path, callback) {
	Nios_call("Nios_fs", "fstat", [fd],  callback ? function (err, stats) {
		stats = new exports.Stats(stats);
		callback(err, stats);
	} : null);
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
	Nios_call("Nios_fs", "watchFile", [filename, options, Nios_registerCallback(function (curr, prev) {
		listener(new exports.Stats(curr), new exports.Stats(prev));
	})]);
}
exports.unwatchFile = function(filename) {
	Nios_call("Nios_fs", "unwatchFile", [filename]);
}
exports.watch = function(filename, options, listener) {
	Nios_call("Nios_fs", "watch", [filename, options, Nios_registerCallback(listener)]);
}

var constants = {
	O_APPEND: 0x0008,	
	O_CREAT: 0x0200,
	O_DIRECTORY: 0x100000,
	O_EXCL: 0x0800,
	O_NOCTTY: 0x20000,
	O_NOFOLLOW: 0x0100,
	O_RDONLY: 0x0000,
	O_RDWR: 0x0002,
	O_SYMLINK: 0x200000,
	O_SYNC: 0x0080,
	O_TRUNC: 0x0400,
	O_WRONLY: 0x0001,
	S_IFMT: 0170000,
	S_IFIFO: 0010000,
	S_IFCHR: 0020000,
	S_IFDIR: 0040000,
	S_IFBLK: 0060000,
	S_IFREG: 0100000,
	S_IFLNK: 0120000,
	S_IFSOCK: 0140000,
	S_IFWHT: 0160000
}

exports.Stats.prototype._checkModeProperty = function(property) {
	return ((this.mode & constants.S_IFMT) === property);
};

exports.Stats.prototype.isDirectory = function() {
	return this._checkModeProperty(constants.S_IFDIR);
};

exports.Stats.prototype.isFile = function() {
	return this._checkModeProperty(constants.S_IFREG);
};

exports.Stats.prototype.isBlockDevice = function() {
	return this._checkModeProperty(constants.S_IFBLK);
};

exports.Stats.prototype.isCharacterDevice = function() {
	return this._checkModeProperty(constants.S_IFCHR);
};

exports.Stats.prototype.isSymbolicLink = function() {
	return this._checkModeProperty(constants.S_IFLNK);
};

exports.Stats.prototype.isFIFO = function() {
	return this._checkModeProperty(constants.S_IFIFO);
};

exports.Stats.prototype.isSocket = function() {
	return this._checkModeProperty(constants.S_IFSOCK);
};