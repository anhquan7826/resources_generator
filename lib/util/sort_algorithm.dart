import 'dart:io';

import 'package:path/path.dart';

int sortFilesByName(FileSystemEntity a, FileSystemEntity b) {
  return basename(a.path).compareTo(basename(b.path));
}