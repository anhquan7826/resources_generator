import 'dart:convert';
import 'dart:io';

import 'package:assets_generator/util/extensions/file_ext.dart';
import 'package:assets_generator/util/filename_util.dart';
import 'package:path/path.dart';

void generateColorResources({
  required String input,
  required String output,
  String? package,
  String? flavor,
}) {
  print('Generating color resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    print('colors/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}color_resources = (
""");
  try {
    final file = directory.listSync().firstWhere(
      (element) {
        return element is File &&
            extension(element.path) == '.json' &&
            !element.isHidden;
      },
    ) as File;
    final line = file.readAsStringSync();
    final map = (json.decode(line) as Map).map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    for (final entry in map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))) {
      buffer.writeln('  ${safeName(entry.key)}: ${entry.value},');
    }
  } catch (_) {}
  buffer.writeln(');');
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'color_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  print('Generated color resources!');
}
