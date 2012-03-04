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
exports.renameSync = function(source, target) {
	Nios_call("Nios_fs", "rename", [source, target], null, true);
}
exports.truncate = function(fd, len, callback) {
	Nios_call("Nios_fs", "truncate", [fd, len], callback);
}
exports.truncateSync = function(fd, len) {
	Nios_call("Nios_fs", "truncate", [fd, len], null, true);
}
exports.chown = function(path, uid, gid, callback) {
	Nios_call("Nios_fs", "chown", [path, uid, gid], callback);
}
exports.chownSync = function(path, uid, gid) {
	Nios_call("Nios_fs", "chown", [path, uid, gid], null, true);
}
exports.lchown = function(path, uid, gid, callback) {
	Nios_call("Nios_fs", "lchown", [path, uid, gid], callback);
}
exports.lchownSync = function(path, uid, gid) {
	Nios_call("Nios_fs", "lchown", [path, uid, gid], null, true);
}
exports.fchown = function(fd, uid, gid, callback) {
	Nios_call("Nios_fs", "fchown", [fd, uid, gid], callback);
}
exports.fchownSync = function(fd, uid, gid) {
	Nios_call("Nios_fs", "fchown", [fd, uid, gid]);
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
exports.chmodSync = function(path, mode) {
	Nios_call("Nios_fs", "chmod", [path, mode]);
}
exports.lchmodSync = function(path, mode) {
	Nios_call("Nios_fs", "lchmod", [path, mode]);
}
exports.fchmodSync = function(fd, mode) {
	Nios_call("Nios_fs", "fchmod", [fd, mode]);
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
exports.statSync = function(path) {
	var stats;
	Nios_call("Nios_fs", "stat", [path], function (err, _stats) {
			  stats = new exports.Stats(_stats);
			  }, true);
	return stats;
}

exports.lstatSync = function(path) {
	var stats;
	Nios_call("Nios_fs", "lstat", [path], function (err, _stats) {
			  stats = new exports.Stats(_stats);
			  }, true);
	return stats;
}

exports.fstatSync = function(path) {
	var stats;
	Nios_call("Nios_fs", "fstat", [fd], function (err, _stats) {
			  stats = new exports.Stats(_stats);
			  }, true);
	return stats;
}

exports.link = function(srcpath, dstpath, callback) {
	Nios_call("Nios_fs", "link", [srcpath, dstpath], callback);
}
exports.linkSync = function(srcpath, dstpath) {
	Nios_call("Nios_fs", "link", [srcpath, dstpath], null, true);
}
exports.symlink = function(linkdata, path, type, callback) {
	Nios_call("Nios_fs", "symlink", [linkdata, path, type], callback);
}
exports.symlinkSync = function(linkdata, path, type) {
	Nios_call("Nios_fs", "symlink", [linkdata, path, type], null, true);
}
exports.readlink = function(path, callback) {
	Nios_call("Nios_fs", "readlink", [path], callback);
}
exports.readlinkSync = function(path) {
	Nios_call("Nios_fs", "readlink", [path], null, true);
}
exports.realpath = function(path, callback) {
	Nios_call("Nios_fs", "realpath", [path], callback);
}
exports.realpathSync = function(path) {
	var ret;
	Nios_call("Nios_fs", "realpath", [path], function(err, resolvedPath) { ret = resolvedPath; }, true);
}
exports.unlink = function(path, callback) {
	Nios_call("Nios_fs", "unlink", [path], callback);
}
exports.unlinkSync = function(path) {
	Nios_call("Nios_fs", "unlink", [path], null, true);
}
exports.rmdir = function(path, callback) {
	Nios_call("Nios_fs", "rmdir", [path], callback);
}
exports.rmdirSync = function(path) {
	Nios_call("Nios_fs", "rmdir", [path], null, true);
}
exports.mkdir = function(path, mode, callback) {
	Nios_call("Nios_fs", "mkdir", [path, mode], callback);
}
exports.mkdirSync = function(path, mode) {
	Nios_call("Nios_fs", "mkdir", [path, mode], null, true);
}
exports.readdir = function(path, callback) {
	Nios_call("Nios_fs", "readdir", [path], callback);
}
exports.readdirSync = function(path) {
	var ret;
	Nios_call("Nios_fs", "readdir", [path], function (err, files) { ret = files; }, true);
	return ret;
}
exports.close = function(fd, callback) {
	Nios_call("Nios_fs", "close", [fd], callback);
}
exports.closeSync = function(fd) {
	Nios_call("Nios_fs", "close", [fd], null, true);
}
exports.open = function(path, flags, mode, callback) {
	Nios_call("Nios_fs", "open", [path, flags, mode || 0666], callback);
}
exports.openSync = function(path, flags, mode) {
	var ret;
	Nios_call("Nios_fs", "open", [path, flags, mode || 0666], function (err, fd) { ret = fd; }, true);
	return ret;
}
exports.utimes = function(path, atime, mtime, callback) {
	Nios_call("Nios_fs", "utimes", [path, atime, mtime], callback);
}
exports.utimesSync = function(path, atime, mtime) {
	Nios_call("Nios_fs", "utimes", [path, atime, mtime], null, true);
}
exports.futimes = function(fd, atime, mtime, callback) {
	Nios_call("Nios_fs", "futimes", [fd, atime, mtime], callback);
}
exports.futimesSync = function(fd, atime, mtime) {
	Nios_call("Nios_fs", "futimes", [fd, atime, mtime], null, true);
}
exports.fsync = function(fd, callback) {
	Nios_call("Nios_fs", "fsync", [fd], callback);
}
exports.fsyncSync = function(fd) {
	Nios_call("Nios_fs", "fsync", [fd], null, true);
}
exports.write = function(fd, buffer, offset, length, position, callback) {
	Nios_call("Nios_fs", "write", [fd, buffer, offset, length, position], callback);
}
exports.writeSync = function(fd, buffer, offset, length, position) {
	if (arguments.length <= 4) {
		position = offset;
		buffer = new Buffer(buffer, length || 'utf8');
		offset = 0;
		length = buffer.length;
	}
	var ret;
	Nios_call("Nios_fs", "write", [fd, buffer, offset, length, position], function (err, written, buffer) { ret = written; }, true);
	return ret;
}
exports.read = function(fd, buffer, offset, length, position, callback) {
	Nios_call("Nios_fs", "read", [fd, buffer, offset, length, position], callback);
}
exports.readSync = function(fd, buffer, offset, length, position) {
	var encoding = false;
	if (arguments.length == 4) {
		encoding = length;
		position = offset;
		length = buffer;
	}
	var ret;
	Nios_call("Nios_fs", "read", [fd, buffer, offset, length, position], function (err, bytesRead, buffer) { ret = bytesRead }, true);
	if (encoding) {
		return [buffer.toString(encoding), ret];
	}
	return ret;
}

exports.readFileSync = function(filename, encoding) {
	if (typeof encoding === 'function' && typeof callback === 'undefined') {
		callback = encoding;
		encoding = null;
	}
	var ret;
	var tmp_callback = function(err, data) {
		if (!err && encoding == null) {
			var str = data;
			ret = string_to_buffer(data);
		} else {
			ret = data;
		}
	}
	Nios_call("Nios_fs", "readFile", [filename, encoding], tmp_callback, true);
	return ret;
}

exports.writeFile = function(filename, data, encoding, callback) {
	Nios_call("Nios_fs", "writeFile", [filename, data, encoding, process._umask], callback);
}
exports.writeFileSync = function(filename, data, encoding) {
	Nios_call("Nios_fs", "writeFile", [filename, data, encoding, process._umask], null, true);
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