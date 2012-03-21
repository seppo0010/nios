window.Buffer = exports.Buffer = function(size, encoding) {
	if (typeof size == 'number') {
		this.length = size;
	} else if (typeof encoding == 'undefined' && Array.isArray(size)) {
		var array = size;
		this.length = array.length;
		for (i=0, limiti=this.length; i < limiti; i++) {
			this[i] = array[i];
		}
	} else {
		var string = size;
		this.length = string.length;
		for (i=0, limiti=this.length; i < limiti; i++) {
			this[i] = string.charCodeAt(i);
		}
	}
};
Buffer.prototype = Object.create(ArrayBuffer.prototype);
Buffer.prototype._isBuffer = true;
Buffer.prototype.dump = function() {
	var str = "<Buffer";
	for (var i = 0; i < this.length; i++) {
		str += " " + this[i].toString(16);
	}
	return str + ">";
}

Buffer.prototype.toString = function(encoding) {
	// TODO: for some reason, socket.io depends on this returning the utf8 string
/*	if (!encoding) {
		var str = "<Buffer";
		for (var i = 0; i < this.length; i++) {
			str += " " + this[i].toString(16);
		}
		return str + ">";
	}*/
	var str = '';
	for (var i = 0; i < this.length; i++) {
		if (this[i] == 0) continue;
		str += String.fromCharCode(this[i] % 256);
	}
	return str;
}

Buffer.prototype.slice = function (start, stop) {
	var len = stop - start + 1;
	var ret = new Buffer(len);
	for (var i = 0; i < len; i++) {
		ret[i] = this[i + start];
	}
	return ret;
}

Buffer.prototype.copy = function(targetBuffer, targetStart, sourceStart, sourceEnd) {
	if (!targetStart) targetStart = 0;
	if (!sourceStart) sourceStart = 0;
	if (!sourceEnd) sourceEnd = this.length;

	for (var i = sourceStart; i < sourceEnd; i++) {
		targetBuffer[targetStart + i] = this[i];
	}
}

Buffer.prototype.write = function(string, offset, length, encoding) {
	// FIXME: use encoding
	if (!offset) offset = 0;
	if (!length) length = buffer.length - offset;
	if (this.length < offset + length) length = this.length - offset;
	for (var i = 0; i < length; i++) {
		this[offset + i] = string.charCodeAt(i);
	}
}

Buffer.isBuffer = function(obj) { return obj._isBuffer == true; }
Buffer.byteLength = function(str, encoding) {
	// FIXME: work properly
	return str.length;
}

