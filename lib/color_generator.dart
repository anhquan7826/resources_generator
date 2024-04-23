import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

void generateColorResources(
    {required String input, required String output, String? package}) {
  final directory = Directory(input);
  if (!directory.existsSync()) {
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names
part of 'resources.dart';

const _colorResources = (
""");
  try {
    final file = directory.listSync().firstWhere(
      (element) {
        return element is File && extension(element.path) == '.json';
      },
    ) as File;
    final line = file.readAsStringSync();
    final map = (json.decode(line) as Map).map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    for (final entry in map.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
      buffer.writeln('  ${entry.key}: ${entry.value},');
    }
  } catch (_) {}
  buffer.writeln(');');
  Directory(output).createSync(recursive: true);
  File('$output/color_resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
}
