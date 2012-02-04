exports.open = function(path, flags, mode, callback) {
	WebViewJavascriptBridge.sendMessage(JSON.stringify({}));
}
