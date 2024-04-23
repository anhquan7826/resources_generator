import 'dart:io';

import 'package:path/path.dart';

void generateFontResources(
    {required String input, required String output, String? package}) {
  final directory = Directory(input);
  if (!directory.existsSync()) {
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names
part of 'resources.dart';

const _fontResources = (
""");
  final files = directory
      .listSync()
      .map((e) {
        if (e is File) {
          if ([
            '.ttf',
            '.otf',
          ].contains(extension(e.path))) {
            return e;
          }
        }
      })
      .whereType<File>()
      .toList()..sort();
  for (final file in files) {
    buffer.writeln(
      "  ${basenameWithoutExtension(file.path)}: '${package == null ? '' : '$package/'}assets/fonts/${basename(file.path)}',",
    );
  }
  buffer.writeln(');');
  Directory(output).createSync(recursive: true);
  File('$output/font_resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
}
