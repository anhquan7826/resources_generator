import 'dart:io';

String getCurrentPath() {
  return Directory.current.path;
}

String getRelativePath(String absolutePath, String basePath) {
  var result = absolutePath.replaceFirst(basePath, '');
  if (result.startsWith('/')) {
    result = result.replaceFirst('/', '');
  }
  return result;
}

