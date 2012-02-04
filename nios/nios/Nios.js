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

var Nios_callbacks = {}
var Nios_lastcallback = 0;

var Nios_call = function(className, method, parameters, callback) {
	var registered_callback = null;
	if (callback) {
		var registered_callback = Nios_lastcallback++;
		Nios_callbacks[registered_callback] = callback;
	}
	WebViewJavascriptBridge.sendMessage(({"class": className, "method": method, "parameters": parameters, "callback": registered_callback}).toJSON())
}

document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady() {
	WebViewJavascriptBridge.setMessageHandler(function(message) {
		alert('Received message: ' + message)
	});
}, false);