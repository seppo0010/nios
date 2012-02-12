window.NIOS_BASEPATH = window.NIOS_BASEPATH || [];

function require_fullpath(path) {
	var module = {
		deprecate: function (deprecate) {
			console.warn(deprecate + ' is deprecated');
		},
		exports: {}
	}
	var exports = {};
	var xhReq = new XMLHttpRequest();
	xhReq.open("GET", "file://" + encodeURI(path), false);
	xhReq.send(null);
	if (xhReq.responseText) {
		try {
			eval(xhReq.responseText);
		} catch (e) { alert("Unable to import module '" + path + "' " + e); }
		for (var k in module.exports) { exports[k] = module.exports[k]; }
		return exports;
	} else {
		alert("Module not found at '" + path + "'");
	}
	return {};
}

function require(filename) {
	if (filename.substr(-3) == '.js') filename = filename.substr(0, -3);
	var exports = {};
	var resolved = require.resolve(filename);
	if (!resolved) return null;
	if (require.cache[resolved]) return require.cache[resolved];
	require.cache[resolved] = require_fullpath(resolved);;
	return require.cache[resolved];
}

require.resolve = function(filename) {
	var exports = {};
	var prefix = ['Nios_', ''];
	for (var k in NIOS_BASEPATH) {
		for (var i in prefix) {
			var path = NIOS_BASEPATH[k] + "/" + prefix[i] + filename + ".js";
			var xhReq = new XMLHttpRequest();
			xhReq.open("HEAD", "file://" + encodeURI(path), false);
			xhReq.send(null);
			var ret = xhReq.responseText;
			if (ret == false) continue;
			return NIOS_BASEPATH[k] + "/" + prefix[i] + filename + ".js";
		}
	}
	return null;
}

require.cache = {};

var console = {
	log: function(str) {
		Nios_call("Nios_console", "log", [Array.prototype.slice.call(arguments, 0).join(' ')]);
	},
	info: function(str) {
		Nios_call("Nios_console", "log", [Array.prototype.slice.call(arguments, 0).join(' ')]);
	},
	warn: function(str) {
		Nios_call("Nios_console", "logerror", [Array.prototype.slice.call(arguments, 0).join(' ')]);
	},
	error: function(str) {
		Nios_call("Nios_console", "logerror", [Array.prototype.slice.call(arguments, 0).join(' ')]);
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

var Nios_initialize = function (arch, platform, port) {
	process.arch = arch;
	process.platform = platform;
	process.startDate = new Date();
	process.env = { NODE_DEBUG: 0 }
	window.Nios_port = port;
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

var Nios_call = function(className, method, parameters, callback, syncronic) {
	if (syncronic) {
		var message = JSON.stringify({"class": className, "method": method, "parameters": parameters });
		var xhReq = new XMLHttpRequest();
		xhReq.open("POST", "http://127.0.0.1:" + Nios_port + "/", false);
		xhReq.send(message);
		if (callback) {
			try {
				var response = JSON.parse(xhReq.responseText);
				callback(response.parameters);
			} catch (e) {
				alert(e);
			}
		}
	} else {
		var message = JSON.stringify({"class": className, "method": method, "parameters": parameters, "callback": Nios_registerCallback(callback)});
		WebViewJavascriptBridge.sendMessage(message);
	}
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
		setTimeout(func, 0);
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

			if (response.callback) {
				Nios_callbacks[response.callback].apply(null, response.parameters);
				if (!response.keepCallback) {
					delete Nios_callbacks[response.callback];
				}
			}
		} catch (e) {
			alert(e);
			return;
		}
	});
}, false);

function string_to_buffer(data) {
	return Base64.decode(data);
}

function buffer_to_string(buf) {
	return Base64.encode(buf);
}

function Nios_ping(callback) {
	Nios_call("Nios", "ping", ["PING?"], callback);
}

require('Buffer')
