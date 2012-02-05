exports.open = function(path, flags, mode, callback) {
	Nios_call("Nios_fs", "open", [path, flags, mode], callback);
}
