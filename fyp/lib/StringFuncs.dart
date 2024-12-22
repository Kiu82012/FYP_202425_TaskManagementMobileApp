extension StringFuncs on String {
  String trimCharLeft(String pattern) {
    if (isEmpty || pattern.isEmpty || pattern.length > length) return this;
    var tmp = this;
    while (tmp.startsWith(pattern)) {
      tmp = tmp.substring(pattern.length);
    }
    return tmp;
  }

  String trimCharRight(String pattern) {
    if (isEmpty || pattern.isEmpty || pattern.length > length) return this;
    var tmp = this;
    while (tmp.endsWith(pattern)) {
      tmp = tmp.substring(0, length - pattern.length);
    }
    return tmp;
  }

  String trimChar(String pattern) {
    return trimCharLeft(pattern).trimCharRight(pattern);
  }
}