import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

void generateStringResources(
    {required String input, required String output, String? package}) {
  final directory = Directory(input);
  if (!directory.existsSync()) {
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names
part of 'resources.dart';

const _stringResources = (
""");
  try {
    final file = directory.listSync().firstWhere(
      (element) {
        return element is File && extension(element.path) == '.json';
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
  Directory(output).createSync(recursive: true);
  File('$output/string_resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
}

void _writeStrings({
  required StringBuffer buffer,
  int indent = 2,
  String prefix = '',
  required Map<String, dynamic> map,
}) {
  for (final entry in map.entries) {
    if (entry.value is String) {
      buffer.writeln(
          "${_generateIndent(indent)}${entry.key}: '$prefix${entry.key}',");
    } else if (entry.value is Map) {
      buffer.writeln("${_generateIndent(indent)}${entry.key}: (");
      _writeStrings(
        buffer: buffer,
        indent: indent + 2,
        prefix: prefix.isEmpty ? '${entry.key}.' : '$prefix.${entry.key}.',
        map: entry.value,
      );
      buffer.writeln("${_generateIndent(indent)}),");
    }
  }
}

String _generateIndent(int length) {
  String result = '';
  for (int i = 0; i < length; i++) {
    result += ' ';
  }
  return result;
}
