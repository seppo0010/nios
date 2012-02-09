exports.lookup = function (domain, family, callback) {
	var args;
	if (arguments.length === 2) {
		args = [domain];
		callback = family;
	} else {
		args = [domain, family];
	}
	Nios_call("Nios_dns", "lookup", args, callback);
}