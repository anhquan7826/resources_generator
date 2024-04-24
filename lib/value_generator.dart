import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

void generateValueResources({
  required String input,
  required String output,
  String? package,
}) {
  print('Generating value resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    print('values/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names
part of 'resources.dart';

const _valueResources = (
""");
  try {
    final files = directory
        .listSync()
        .where(
          (element) => element is File && extension(element.path) == '.json',
        )
        .cast<File>()
        .toList()
      ..sort((a, b) => basename(a.path).compareTo(basename(b.path)));
    for (var file in files) {
      final line = file.readAsStringSync();
      final map = (json.decode(line) as Map).map((key, value) {
        return MapEntry(key.toString(), value);
      });
      buffer.writeln('  ${basenameWithoutExtension(file.path)}: (');
      _writeStrings(
        indent: 4,
        buffer: buffer,
        map: map,
      );
      buffer.writeln('  ),');
    }
  } catch (_) {}
  buffer.writeln(');');
  Directory(output).createSync(recursive: true);
  File('$output/value_resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  print('Generated values resources!');
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
