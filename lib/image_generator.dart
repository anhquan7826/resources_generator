import 'dart:io';

import 'package:path/path.dart';

void generateImageResources({
  required String input,
  required String output,
  String? package,
}) {
  print('Generating image resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    print('images/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names
part of 'resources.dart';

const _imageResources = (
""");
  final files = directory
      .listSync()
      .map((e) {
        if (e is File) {
          if ([
            '.png',
            '.jpg',
            '.jpeg',
            '.bmp',
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
      "  ${basenameWithoutExtension(file.path)}: '${package == null ? '' : '$package/'}assets/images/${basename(file.path)}',",
    );
  }
  buffer.writeln(');');
  Directory(output).createSync(recursive: true);
  File('$output/image_resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  print('Generated image resources!');
}
