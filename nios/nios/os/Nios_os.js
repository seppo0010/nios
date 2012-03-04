exports.hostname = function() {
	var ret;
	Nios_call("Nios_os", "hostname", [], function (hostname) { ret = hostname; }, true);
	return ret;
}

exports.type = function() {
	var ret;
	Nios_call("Nios_os", "type", [], function (type) { ret = type; }, true);
	return ret;
}

exports.platform = function() {
	return process.platform;
}

exports.arch = function() {
	return process.arch;
}

exports.release = function() {
	var ret;
	Nios_call("Nios_os", "release", [], function (release) { ret = release; }, true);
	return ret;
}

