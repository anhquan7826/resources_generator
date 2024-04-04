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
      return MapEntry(key.toString(), value.toString());
    });
    for (final key in map.keys) {
      buffer.writeln("  $key: '$key',");
    }
  } catch (_) {}
  buffer.writeln(');');
  Directory(output).createSync(recursive: true);
  File('$output/string_resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
}
