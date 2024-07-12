import 'dart:io';

import 'package:assets_generator/util/extensions/file_ext.dart';
import 'package:assets_generator/util/filename_util.dart';
import 'package:assets_generator/util/path_util.dart';
import 'package:path/path.dart';

void generateRawResources({
  required String input,
  required String output,
  String? package,
  String? flavor,
}) {
  print('Generating raw resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    print('raw/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}raw_resources = (
""");
  final files = directory.listSync().where((element) {
    return element is File && !element.isHidden;
  }).toList()
    ..sort((a, b) => basename(a.path).compareTo(basename(b.path)));
  for (final file in files) {
    final relativePath = getRelativePath(
      file.absolute.uri.path,
      getCurrentPath(),
    );
    final fullPath =
        (package == null ? '' : 'packages/$package/') + relativePath;
    buffer.writeln(
      "  ${safeName(basenameWithoutExtension(file.path))}: '$fullPath',",
    );
  }
  buffer.writeln(');');
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'raw_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  print('Generated raw resources!');
}
