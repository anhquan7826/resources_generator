import 'dart:io';

import 'package:path/path.dart';

void generateVectorResources(
    {required String input, required String output, String? package}) {
  final directory = Directory(input);
  if (!directory.existsSync()) {
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names
part of 'resources.dart';

const _vectorResources = (
""");
  final files = directory
      .listSync()
      .map((e) {
        if (e is File) {
          if (extension(e.path) == '.svg') {
            return e;
          }
        }
      })
      .whereType<File>()
      .toList()..sort();
  for (final file in files) {
    buffer.writeln(
      "  ${basenameWithoutExtension(file.path)}: '${package == null ? '' : 'packages/$package/'}assets/vectors/${basename(file.path)}',",
    );
  }
  buffer.writeln(');');
  Directory(output).createSync(recursive: true);
  File('$output/vector_resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
}
