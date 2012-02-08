window.Buffer = exports.Buffer = function(size, encoding) {
	if (typeof size == 'number') {
		this.length = size;
	} else {
		var string = size;
		this.length = string.length;
		for (i=0, limiti=this.length; i < limiti; i++) {
			this[i] = string.charCodeAt(i);
		}
	}
};
Buffer.prototype = Object.create(ArrayBuffer.prototype);
