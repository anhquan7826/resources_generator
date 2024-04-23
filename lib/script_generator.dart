import 'dart:io';

import 'package:path/path.dart';

void generateScriptResources({
  required String input,
  required String output,
  String? package,
}) {
  print('Generating script resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    print('scripts/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names
part of 'resources.dart';

const _scriptResources = (
""");
  final files = directory
      .listSync()
      .map((e) {
        if (e is File) {
          if ([
            '.sh',
            '.bat',
          ].contains(extension(e.path))) {
            return e;
          }
        }
      })
      .whereType<File>()
      .toList()
    ..sort((a, b) => basename(a.path).compareTo(basename(b.path)));
  for (final file in files) {
    buffer.writeln(
      "  ${basenameWithoutExtension(file.path)}: '${package == null ? '' : '$package/'}assets/scripts/${basename(file.path)}',",
    );
  }
  buffer.writeln(');');
  Directory(output).createSync(recursive: true);
  File('$output/script_resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  print('Generated script resources!');
}
