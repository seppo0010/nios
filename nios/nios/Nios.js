window.NIOS_BASEPATH = window.NIOS_BASEPATH || [];

var module = {
	deprecate: function (deprecate) {
		console.warn(deprecate + ' is deprecated');
	}
}
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
	if (require.cache[filename]) return;
	if (filename.substr(-3) == '.js') filename = filename.substr(0, -3);
	var exports = {};
	var prefix = ['Nios_', ''];
	for (var k in NIOS_BASEPATH) {
		for (var i in prefix) {
			var ret = require_fullpath(NIOS_BASEPATH[k] + "/" + prefix[i] + filename + ".js");
			if (ret == false) continue;
			return ret;
		}
	}
	return exports;
}

require.resolve = function(filename) {
	var exports = {};
	for (var k in NIOS_BASEPATH) {
		var ret = require_fullpath(NIOS_BASEPATH[k] + "/Nios_" + filename + ".js");
		if (ret == false) continue;
		return NIOS_BASEPATH[k] + "/Nios_" + filename + ".js";
	}
	return null;
}

require.cache = {};

var Buffer = ArrayBuffer;

var console = {
	log: function(str) {
		Nios_call("Nios_console", "log", [str]);
	},
	info: function(str) {
		Nios_call("Nios_console", "log", [str]);
	},
	warn: function(str) {
		Nios_call("Nios_console", "logerror", [str]);
	},
	error: function(str) {
		Nios_call("Nios_console", "logerror", [str]);
	},
	dir: function(obj) {
		// TODO
	},
	timeLabels: {},
	time: function(label) {
		this.timeLabels[label] = new Date();
	},
	timeEnd: function(label) {
		this.log(label + ': ' + ((new Date()).getTime() - this.timeLabels[label].getTime()) + 'ms');
	},
	trace: function () {
		// TODO
	},
	assert: function() {
		// TODO
	}
}

var Nios_initialize = function (arch, platform) {
	process.arch = arch;
	process.platform = platform;
	process.startDate = new Date();
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
window.process = {
	onExit: [],
	onUncaughtException: [],
	on: function (evt, func) {
		//TODO: signals
		var type = 'on' + evt.substr(0,1).toUpperCase() + evt.substr(1);
		if (this[type] instanceof Array) {
			this[type].push(func);
		} else {
			alert('Unknown event \'' + evt + '\'');
		}
	},
	argv: [],
	execPath: null,
	env: {},
	setuid: function (uid) { },
	getuid: function () { return 0; },
	setgid: function (gid) { },
	getgid: function () { return 0; },
	version: '0.0',
	versions: { "nios" : '0.0' },
	installPrefix: null,
	kill: function (pid, signal) {},
	pid: 0,
	title: null,
	arch: null,
	platform: null,
	memoryUsage: function () { return 0; },
	umask: function (umask) {},
	startDate: null,
	uptime: function () {
		return ((new Date()).getTime() - startDate.getTime) / 1000;
	},
	chdir: function (dir) {
		//TODO
	},
	cwd: function () {
		//TODO
	},
	exit: function (code) {
		alert(code);
		Nios_call("Nios_process", "exit", [code]);
	},
	nextTick: function (func) {
	
	},
	stdout: {
		write: function(str) {
			//TODO
		}
	},
	stdin: {
		encoding: 'utf8',
		resume: function() {},
		pause: function() {},
		setEncoding: function(enc) {
			this.encoding = enc;
		},
		onData: [],
		onEnd: [],
		on: function(evt, func) {
			if (this[type] instanceof Array) {
				this[type].push(func);
			} else {
				alert('Unknown event \'' + evt + '\'');
			}
		}
	},
	stderr: {
		write: function(str) {
			//TODO
		}
	}
};

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

function string_to_buffer(data) {
	var buffer = new Buffer(data.length);
	for (var i = 0; i < data.length; i++) {
		buffer[i] = data[i];
	}
	return buffer;
}