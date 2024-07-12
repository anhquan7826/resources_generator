import 'dart:io';

import 'package:path/path.dart';

extension FileSystemEntityExtension on FileSystemEntity {
  bool get isHidden {
    return basename(path).startsWith(RegExp('[._]'));
  }
}
