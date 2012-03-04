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

exports.uptime = function() {
	var ret;
	Nios_call("Nios_os", "uptime", [], function (uptime) { ret = uptime; }, true);
	return ret;
}

exports.cpus = function() {
	var ret;
	Nios_call("Nios_os", "cpus", [], function (cpus) { ret = cpus; }, true);
	return ret;
}

exports.networkInterfaces = function() {
	var ret;
	Nios_call("Nios_os", "networkInterfaces", [], function (networkInterfaces) { ret = networkInterfaces; }, true);
	return ret;
}