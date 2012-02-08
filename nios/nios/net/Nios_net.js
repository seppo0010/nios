exports.isIP = function(input) {
  if (!input) {
    return 4;
  } else if (/^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$/.test(input)) {
    var parts = input.split('.');
    for (var i = 0; i < parts.length; i++) {
      var part = parseInt(parts[i]);
      if (part < 0 || 255 < part) {
        return 0;
      }
    }
    return 4;
  } else if (/^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$/.test(
      input)) {
    return 6;
  } else {
    return 0;
  }
};


exports.isIPv4 = function(input) {
  return exports.isIP(input) === 4;
};


exports.isIPv6 = function(input) {
  return exports.isIP(input) === 6;
};
