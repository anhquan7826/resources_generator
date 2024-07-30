import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';

int sortFilesByName(FileSystemEntity a, FileSystemEntity b) {
  return basename(a.unixPath).compareTo(basename(b.unixPath));
}