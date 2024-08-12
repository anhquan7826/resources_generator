import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/filename_util.dart';
import 'package:resources_generator/util/logger.dart';
import 'package:resources_generator/util/sort_algorithm.dart';
import 'package:resources_generator/util/writer.dart';

void generateConfigResources({
  required String input,
  required String output,
  String? package,
  String? flavor,
}) {
  Logger.verboseLog('Generating config resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    Logger.verboseLog('configs/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer(
    """
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}config_resources = (\n""",
  );
  try {
    final files = directory
        .listSync()
        .where(
          (element) =>
              element is File &&
              extension(element.unixPath) == '.json' &&
              !element.isHidden,
        )
        .cast<File>()
        .toList()
      ..sort(sortFilesByName);
    for (final file in files) {
      final line = file.readAsStringSync();
      final object = json.decode(line);
      buffer.write('  ${safeName(basenameWithoutExtension(file.unixPath))}: ');
      if (object is Map) {
        Writer(buffer).writeRecord(
          4,
          object.map((key, value) => MapEntry(key, value)),
        );
      }
      buffer.write(',\n');
    }
  } catch (_) {}
  buffer.writeln(');');
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'config_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  Logger.verboseLog('Generated config resources!');
}
