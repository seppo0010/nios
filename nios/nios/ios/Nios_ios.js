exports.vibrate = function(callback) {
	if (callback) {
		Nios_call("Nios_ios", "vibrate", [callback]);
	} else {
		Nios_call("Nios_ios", "vibrate");
	}
}
exports.alert = function(title, text) {
	Nios_call("Nios_ios", "alert", [title || "", text || ""]);
}