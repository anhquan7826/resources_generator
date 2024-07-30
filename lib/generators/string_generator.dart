import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/filename_util.dart';
import 'package:resources_generator/util/logger.dart';

void generateStringResources({
  required String input,
  required String output,
  String? package,
  String? flavor,
}) {
  Logger.verboseLog('Generating string resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    Logger.verboseLog('translations/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}string_resources = (
""");
  try {
    final file = directory.listSync().firstWhere(
      (element) {
        return element is File && extension(element.path) == '.json' && !element.isHidden;
      },
    ) as File;
    final line = file.readAsStringSync();
    final map = (json.decode(line) as Map).map((key, value) {
      return MapEntry(key.toString(), value);
    });
    _writeStrings(
      buffer: buffer,
      map: map,
    );
  } catch (_) {}
  buffer.writeln(');');
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'string_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  Logger.verboseLog('Generated string resources!');
}

void _writeStrings({
  required StringBuffer buffer,
  int indent = 2,
  String prefix = '',
  required Map<String, dynamic> map,
}) {
  for (final entry in map.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key))) {
    if (entry.value is String) {
      buffer.writeln(
          "${_generateIndent(indent)}${safeName(entry.key)}: '$prefix${entry.key}',");
    } else if (entry.value is Map) {
      buffer.writeln('${_generateIndent(indent)}${entry.key}: (');
      _writeStrings(
        buffer: buffer,
        indent: indent + 2,
        prefix: prefix.isEmpty ? '${entry.key}.' : '$prefix.${entry.key}.',
        map: entry.value,
      );
      buffer.writeln('${_generateIndent(indent)}),');
    }
  }
}

String _generateIndent(int length) {
  final result = StringBuffer();
  for (int i = 0; i < length; i++) {
    result.write(' ');
  }
  return result.toString();
}
