import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/filename_util.dart';
import 'package:resources_generator/util/logger.dart';
import 'package:resources_generator/util/path_util.dart';
import 'package:resources_generator/util/sort_algorithm.dart';

void generateFontResources({
  required String input,
  required String output,
  String? package,
  String? flavor,
}) {
  Logger.verboseLog('Generating font resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    Logger.verboseLog('fonts/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}font_resources = (
""");
  final files = directory.listSync().where((element) {
    return element is File &&
        [
          '.ttc',
          '.ttf',
          '.otf',
        ].contains(extension(element.unixPath)) &&
        !element.isHidden;
  }).toList()
    ..sort(sortFilesByName);
  for (final file in files) {
    final relativePath = getRelativePath(
      file.absolute.unixPath,
      getCurrentPath(),
    );
    final name = safeName(basenameWithoutExtension(file.unixPath));
    final fullPath =
        (package == null ? '' : 'packages/$package/') + relativePath;
    buffer
      ..writeln('  $name: (')
      ..writeln("    name: '$name',")
      ..writeln("    path: '$fullPath',")
      ..writeln('  ),');
  }
  buffer.writeln(');');
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'font_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  Logger.verboseLog('Generated font resources!');
}
