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

Buffer.byteLength = function(str, encoding) {
	// FIXME: work properly
	return str.length;
}

window.Base64 = {
	
	// private property
	_keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
	
	// public method for encoding
	encode : function (input) {
		var output = "";
		var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
		var i = 0;

		input = new Uint8Array(input);

		while (i < input.length) {
			
			chr1 = input[i++];
			chr2 = input[i++];
			chr3 = input[i++];
			
			enc1 = chr1 >> 2;
			enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			enc4 = chr3 & 63;
			
			if (isNaN(chr2)) {
				enc3 = enc4 = 64;
			} else if (isNaN(chr3)) {
				enc4 = 64;
			}
			
			output = output +
			this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
			this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4);
			
		}
		
		return output;
	},
	
	// public method for decoding
	decode : function (input) {
		var output = new Buffer(Math.ceil(3 / 4 * input.length));
		var chr1, chr2, chr3;
		var enc1, enc2, enc3, enc4;
		var i = 0, j = 0;
		
		input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
		
		while (i < input.length) {
			
			enc1 = this._keyStr.indexOf(input.charAt(i++));
			enc2 = this._keyStr.indexOf(input.charAt(i++));
			enc3 = this._keyStr.indexOf(input.charAt(i++));
			enc4 = this._keyStr.indexOf(input.charAt(i++));
			
			chr1 = (enc1 << 2) | (enc2 >> 4);
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			chr3 = ((enc3 & 3) << 6) | enc4;
			
			output[j++] = chr1;
			
			if (enc3 != 64) {
				output[j++] = chr2;
			}
			if (enc4 != 64) {
				output[j++] = chr3;
			}
			
		}
		
		return output;
		
	}
}