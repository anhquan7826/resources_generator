import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/filename_util.dart';
import 'package:resources_generator/util/logger.dart';
import 'package:resources_generator/util/sort_algorithm.dart';
import 'package:resources_generator/util/writer.dart';

void generateValueResources({
  required String input,
  required String output,
  String? flavor,
}) {
  Logger.verboseLog('Generating value resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    Logger.verboseLog('values/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer();
  _genStart(buffer, flavor);
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
          recursive: false,
        );
      } else if (object is List) {
        Writer(buffer).writeList(4, object);
      } else if (object is String) {
        Writer(buffer).writeString(0, object);
      } else {
        Writer(buffer).writeAny(0, object);
      }
      buffer.write(',\n');
    }
  } catch (_) {}
  _genFinish(buffer, output, flavor);
}

void _genStart(StringBuffer buffer, String? flavor) {
  buffer.write(
    """
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}value_resources = (\n""",
  );
}

void _genFinish(StringBuffer buffer, String output, String? flavor) {
  buffer.writeln(');');
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'value_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  Logger.verboseLog('Generated values resources!');
}
