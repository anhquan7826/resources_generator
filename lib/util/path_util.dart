import 'dart:io';

import 'package:resources_generator/util/extensions/file_ext.dart';

String getCurrentPath() {
  return Directory.current.unixPath;
}

String getRelativePath(String absolutePath, String basePath) {
  var result = absolutePath.replaceFirst(basePath, '');
  if (result.startsWith('/')) {
    result = result.replaceFirst('/', '');
  }
  return result;
}

