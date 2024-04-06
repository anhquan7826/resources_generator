import 'dart:io';

import 'package:path/path.dart';

void generateRootResources(
    {required String output, String? package}) {
  final directory = Directory(output);
  final buffer = StringBuffer();
  final files = directory
      .listSync()
      .map((e) {
    if (e is File) {
      if (extension(e.path) == '.dart' && basename(e.path) != 'resources.dart') {
        return e;
      }
    }
  })
      .whereType<File>()
      .toList();
  for (final file in files) {
    buffer.writeln("part '${basename(file.path)}';");
  }
  buffer.writeln(
'''

class R {
  R._();
'''
  );
  for (final file in files) {
    switch (basenameWithoutExtension(file.path)) {
      case 'string_resources':
        buffer.writeln('  static const strings = _stringResources;');
        break;
      case 'image_resources':
        buffer.writeln('  static const images = _imageResources;');
        break;
      case 'vector_resources':
        buffer.writeln('  static const vectors = _vectorResources;');
        break;
      case 'font_resources':
        buffer.writeln('  static const fonts = _fontResources;');
        break;
      case 'script_resources':
        buffer.writeln('  static const scripts = _scriptResources;');
        break;
      case 'color_resources':
        buffer.writeln('  static const colors = _colorsResources;');
        break;
    }
  }
  buffer.writeln('}');
  Directory(output).createSync(recursive: true);
  File('$output/resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
}
