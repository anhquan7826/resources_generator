import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/filename_util.dart';
import 'package:resources_generator/util/logger.dart';
import 'package:resources_generator/util/path_util.dart';
import 'package:resources_generator/util/sort_algorithm.dart';

void generateVectorResources({
  required String input,
  required String output,
  String? package,
  String? flavor,
}) {
  Logger.verboseLog('Generating vector resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    Logger.verboseLog('vectors/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}vector_resources = (
""");
  final files = directory.listSync().where((element) {
    return element is File &&
        extension(element.unixPath) == '.svg' &&
        !element.isHidden;
  }).toList()
    ..sort(sortFilesByName);
  for (final file in files) {
    final relativePath = getRelativePath(
      file.absolute.unixPath,
      getCurrentPath(),
    );
    final fullPath =
        (package == null ? '' : 'packages/$package/') + relativePath;
    buffer.writeln(
      "  ${safeName(basenameWithoutExtension(file.unixPath))}: '$fullPath',",
    );
  }
  buffer.writeln(');');
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'vector_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  Logger.verboseLog('Generated vector resources!');
}
