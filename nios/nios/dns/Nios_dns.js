exports.lookup = function (domain, family, callback) {
	var args;
	if (arguments.length === 2) {
		args = [domain, callback];
	} else {
		args = [domain, family, callback];
	}
	Nios_call("Nios_dns", "lookup", args, callback);
}