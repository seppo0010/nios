window.NIOS_BASEPATH = window.NIOS_BASEPATH || [];

function require_fullpath(path) {
	var xhReq = new XMLHttpRequest();
	var exports = {};
	xhReq.open("GET", "file://" + encodeURI(path), false);
	xhReq.send(null);
	if (xhReq.responseText) {
		eval(xhReq.responseText);
		return exports;
	}
	return false;
}

function require(filename) {
	var exports = {};
	for (var k in NIOS_BASEPATH) {
		var ret = require_fullpath(NIOS_BASEPATH[k] + "/Nios_" + filename + ".js");
		if (ret == false) continue;
		return ret;
	}
	return exports;
}

var Buffer = ArrayBuffer;

var console = {
	log: function(str) {
		Nios_call("Nios_console", "log", [str]);
	}
}
var Nios_callbacks = {}
var Nios_lastcallback = 0;

var Nios_registerCallback = function(callback) {
	var registered_callback = null;
	if (callback) {
		var registered_callback = ++Nios_lastcallback;
		Nios_callbacks[registered_callback] = callback;
	}
	return registered_callback;
}

var Nios_call = function(className, method, parameters, callback) {
	WebViewJavascriptBridge.sendMessage(JSON.stringify({"class": className, "method": method, "parameters": parameters, "callback": Nios_registerCallback(callback)}))
}

document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady() {
	WebViewJavascriptBridge.setMessageHandler(function(message) {
		try {
			var response = JSON.parse(message);
		} catch (e) {
			alert(e);
			return;
		}

		if (response.callback) {
			Nios_callbacks[response.callback].apply(null, response.parameters);
			if (!response.keepCallback) {
				delete Nios_callbacks[response.callback];
			}
		}
	});
}, false);