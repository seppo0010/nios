try {
window.NIOS_BASEPATH = window.NIOS_BASEPATH || [];

window.currentPath = [];
window._modules = [];

function require_fullpath(path) {
	var module = {
		deprecate: function (deprecate) {
			console.warn(deprecate + ' is deprecated');
		},
		exports: {}
	}
	if (window._modules.length > 0) {
		module.parent = window._modules[window._modules.length - 1];
	}
	var exports = module.exports;
	var xhReq = new XMLHttpRequest();
	xhReq.open("GET", "file://" + encodeURI(path), false);
	xhReq.send(null);
	if (xhReq.responseText) {
		var __dirname = path.split('/').slice(0, -1).join('/')
		currentPath.push(__dirname);
		window._modules.push(module);
		var responseText = xhReq.responseText;
											
		// XXX: this is awful, and I'm not proud of it :(
		// socket.io has that line and seems to have problem with the device parser
		// I'd rather hard-code it here than patching socket.io at the moment
		// don't use a generic 'default:' since it breaks the switch structures
		responseText = responseText.replace("default: require('./default')", "'default': require('./default')");
		responseText = responseText.replace(/\.in =/g, "['in'] =");
		responseText = responseText.replace(/\.in\(/g, "['in'](");

		eval(responseText);
		window._modules.pop();
		currentPath.pop();
		for (var k in exports) { module.exports[k] = exports[k]; }
		return module.exports;
	} else {
		alert("Module not found at '" + path + "'");
	}
	return {};
}

function require(filename) {
	var exports = {};
	var resolved = require.resolve(filename);
	if (!resolved) return null;
	if (require.cache[resolved]) return require.cache[resolved];
	require.cache[resolved] = {}; // temporary empty object, avoid circular reference
	require.cache[resolved] = require_fullpath(resolved);;
	return require.cache[resolved];
}

function basepath(p) {
	if (p.length == 0) return p;

	var shouldPrepend = false;
	if (p[0] == '/') shouldPrepend = true;
	var shouldAppend = false;
	if (p[p.length - 1] == '/') shouldAppend = true;

	var path = p.split('/');
	var ret = [];
	for (var k in path) {
		if (path[k] == '' || path[k] == '.') continue;
		else if (path[k] == '..') ret.pop();
		else ret.push(path[k]);
	}
	return (shouldPrepend ? '/' : '') + ret.join('/') + (shouldAppend ? '/' : '');
}
	
require.resolve = function(filename) {
	var exports = {};
	var prefix;
	var suffix = ['', '.js'];
	var path;
	if (filename.substr(0,1) == '/') {
		path = [''];
		prefix = ['', 'node_modules'];
	} else if (filename.substr(0,2) == './' || filename.substr(0,3) == '../') {
		path = [window.currentPath[window.currentPath.length - 1]];
		prefix = ['', 'node_modules'];
	} else {
		path = [];
		for (var k in NIOS_BASEPATH) {
			path.unshift(NIOS_BASEPATH[k]);
			path.unshift(NIOS_BASEPATH[k] + '/node_modules');
		}
		if (window.currentPath && window.currentPath.length > 0) {
			var _currentPath = window.currentPath[window.currentPath.length - 1].split('/');
			var c = _currentPath.length;
			for (var i = 0; i < c; i++) {
				path.unshift(_currentPath.join('/') + '/node_modules');
				_currentPath = _currentPath.slice(0, -1);
			}
		}
		prefix = ['Nios_', '']
	}

	for (var k in path) {
		for (var i in prefix) {
			for (var j in suffix) {
				var _currentPath = path[k] + "/" + prefix[i] + filename + suffix[j];
				var xhReq = new XMLHttpRequest();
				xhReq.open("HEAD", "file://" + encodeURI(_currentPath), false);
				xhReq.send(null);
				var ret = xhReq.responseText;
				if (ret == false) continue;
				return basepath(_currentPath);
			}
		}
		var _currentPath = path[k] + "/" + filename + "/package.json";
		var xhReq = new XMLHttpRequest();
		xhReq.open("GET", "file://" + encodeURI(_currentPath), false);
		xhReq.send(null);
		var ret = xhReq.responseText;
		if (ret) {
			var package = JSON.parse(ret);
			if (package) {
				return require.resolve(path[k] + "/" + filename + "/" + package.main);
			}
		}
		_currentPath = path[k] + "/" + filename + "/index.js";
		xhReq = new XMLHttpRequest();
		xhReq.open("HEAD", "file://" + encodeURI(_currentPath), false);
		xhReq.send(null);
		var ret = xhReq.responseText;
		if (ret) {
			return basepath(_currentPath);
		}
	}
	return null;
}

require.cache = {};

var console = {
	log: function(str) {
		process.stdout.write(Array.prototype.slice.call(arguments, 0).join(' ') + "\n");
	},
	info: function(str) {
		process.stdout.write(Array.prototype.slice.call(arguments, 0).join(' ') + "\n");
	},
	warn: function(str) {
		process.stderr.write(Array.prototype.slice.call(arguments, 0).join(' ') + "\n");
	},
	error: function(str) {
		process.stderr.write(Array.prototype.slice.call(arguments, 0).join(' ') + "\n");
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

var Nios_initialize = function (arch, platform, pid, port) {
	process.arch = arch;
	process.platform = platform;
	process.pid = pid;
	process.startDate = new Date();
	process.env = { NODE_DEBUG: 0 }
	window.Nios_port = port;
	var Stdin = function(options) {
		var self = this;
		stream.Stream.call(this);
		this.encoding = 'utf8';
		this._paused = true;
		this.resume = function() {
			self._paused = false;
			if (self._buffered.length > 0) {
				self.emit('data', self._buffered);
			}
		};
		this.pause = function() {
			self._paused = true;
		};
		this._buffered = "";
		this.setEncoding = function(enc) {
			self.encoding = enc;
		};
	}

	var util = require('util');
	var events = require('events');
	var stream = require('stream');
											
	util.inherits(Stdin, events.EventEmitter);
	process.stdin = new Stdin();
	Nios_registerCallback('stdindata', function (data) {
		var buffer = string_to_buffer(data);
		if (process.stdin._paused) {
			process.stdin._buffered += buffer.toString(process.stdin.encoding);
			// FIXME: should use current encoding, or the one when resuming it?
		} else {
			process.stdin.emit('data', buffer.toString(process.stdin.encoding));
		}
	});									
}
var Nios_callbacks = {}
var Nios_lastcallback = 0;

var Nios_registerCallback = function(_name, _callback) {
	var callback, name;
	if (typeof _callback === 'undefined') {
		if (typeof _name === 'undefined') {
			return null;
		}
		callback = _name;
		name = ++Nios_lastcallback;
	} else {
		callback = _callback;
		name = _name;
	}

	Nios_callbacks[name] = callback;
	return name;
}

var Nios_call = function(className, method, parameters, callback, syncronic) {
	if (syncronic) {
		var message = JSON.stringify({"class": className, "method": method, "parameters": parameters });
		var xhReq = new XMLHttpRequest();
		xhReq.open("POST", "http://127.0.0.1:" + Nios_port + "/", false);
		xhReq.send(message);
		if (callback) {
			var response = JSON.parse(xhReq.responseText);
			callback(response.parameters);
		}
	} else {
		if (!window.WebViewJavascriptBridge) {
			Nios_call(className, method, parameters, callback, true);
			return;
		}
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
			Nios_call("Nios", "writeStdout", [str], null, true);
			// Note: according to node.js docs, this method is usually blocking
		}
	},
	stderr: {
		write: function(str) {
			Nios_call("Nios", "writeStderr", [str], null, true);
			// Note: according to node.js docs, this method is usually blocking
		}
	},
	EventEmitter: require('events').EventEmitter
};

function onBridgeReady() {
	Nios_call("Nios", "didFinishLoading", []);
	WebViewJavascriptBridge.setMessageHandler(function(message) {
		var response = JSON.parse(message);

		if (response.callback) {
			if (typeof Nios_callbacks[response.callback] === 'undefined') { alert("Something bad happened, the callback '" + response.callback + "' does not exist!"); return; }; // TODO: use assert
			Nios_callbacks[response.callback].apply(null, response.parameters);
			if (!response.keepCallback) {
				delete Nios_callbacks[response.callback];
			}
		}
	});
}

function string_to_buffer(data) {
	var binary = atob(data);
	var buffer = new Buffer(binary.length);
	for (var i = 0; i < binary.length; i++) {
		buffer[i] = binary.charCodeAt(i);
	}
	return buffer;
}

function buffer_to_string(buf) {
	var str = "";
	for (var i = 0; i < buf.length; i++) {
		str += String.fromCharCode(buf[i]);
	}
	return btoa(str);
}

function Nios_ping(callback) {
	Nios_call("Nios", "ping", ["PING?"], callback);
}
											
var methods = (function() {
	var slice = Array.prototype.slice;

	function update(array, args) {
		var arrayLength = array.length, length = args.length;
		while (length--) array[arrayLength + length] = args[length];
		return array;
	}

	function merge(array, args) {
		array = slice.call(array, 0);
		return update(array, args);
	}

	function argumentNames() {
		var names = this.toString().match(/^[\s\(]*function[^(]*\(([^)]*)\)/)[1]
		.replace(/\/\/.*?[\r\n]|\/\*(?:.|[\r\n])*?\*\//g, '')
		.replace(/\s+/g, '').split(',');
		return names.length == 1 && !names[0] ? [] : names;
	}

	function bind(context) {
		if (arguments.length < 2 && arguments[0] === 'undefined') return this;
		var __method = this, args = slice.call(arguments, 1);
		return function() {
			var a = merge(args, arguments);
			return __method.apply(context, a);
		}
	}

	function curry() {
		if (!arguments.length) return this;
		var __method = this, args = slice.call(arguments, 0);
		return function() {
			var a = merge(args, arguments);
			return __method.apply(this, a);
		}
	}

	function delay(timeout) {
		var __method = this, args = slice.call(arguments, 1);
		timeout = timeout * 1000;
		return window.setTimeout(function() {
			return __method.apply(__method, args);
		}, timeout);
	}

	function defer() {
		var args = update([0.01], arguments);
		return this.delay.apply(this, args);
	}

	function wrap(wrapper) {
		var __method = this;
		return function() {
			var a = update([__method.bind(this)], arguments);
			return wrapper.apply(this, a);
		}
	}

	function methodize() {
		if (this._methodized) return this._methodized;
		var __method = this;
		return this._methodized = function() {
			var a = update([this], arguments);
			return __method.apply(null, a);
		};
	}

	return {
		argumentNames:       argumentNames,
		bind:                bind,
		curry:               curry,
		delay:               delay,
		defer:               defer,
		wrap:                wrap,
		methodize:           methodize
	}
})();
for (var k in methods) {
	Function.prototype[k] = methods[k];
}
require('buffer')
}catch (e) { alert(e); }
