import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/extensions/scope_ext.dart';
import 'package:resources_generator/util/filename_util.dart';
import 'package:resources_generator/util/logger.dart';
import 'package:resources_generator/util/sort_algorithm.dart';

void generateColorResources({
  required String input,
  required String output,
  String? package,
  String? flavor,
}) {
  Logger.verboseLog('Generating color resources...');
  final directory = Directory(input);
  if (!directory.existsSync()) {
    Logger.verboseLog('colors/ folder is not exist. Skipping...');
    return;
  }
  final buffer = StringBuffer("""
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}color_resources = (
""");
  try {
    final files = directory.listSync().where((fs) {
      return fs is File &&
          extension(fs.path) == '.json' &&
          !fs.isHidden &&
          basenameWithoutExtension(fs.path).startsWith('colors');
    }).cast<File>().toList()..sort(sortFilesByName);
    if (files.length == 1) {
      _writeColorsSingle(files.first, buffer);
    } else if (files.length > 1) {
      _writeColorsMultiple(files, buffer);
    }
  } catch (_) {}
  buffer.writeln(');');
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'color_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  Logger.verboseLog('Generated color resources!');
}

void _writeColorsSingle(File file, StringBuffer buffer) {
  final line = file.readAsStringSync();
  final object = json.decode(line);
  if (object is Map) {
    for (final entry in object.entries) {
      if (entry.value.toString().isEmpty) {
        continue;
      }
      buffer.write('  ${safeName(entry.key)}: ');
      if (entry.value is Map) {
        _genMap(buffer, 4, entry.value);
      } else if (entry.value is List) {
        _genList(buffer, 4, entry.value);
      } else {
        _genValue(buffer, 0, entry.value);
      }
      buffer.write(',\n');
    }
  }
}

void _writeColorsMultiple(Iterable<File> files, StringBuffer buffer) {
  for (final file in files) {
    final line = file.readAsStringSync();
    final object = json.decode(line);
    if (object is! Map) {
      continue;
    }
    final variant = basenameWithoutExtension(file.path).let((it) {
      String name;
      try {
        name = it.substring('colors_'.length);
      } catch (_) {
        name = '';
      }
      if (name.isEmpty) {
        return 'default';
      } else {
        return name;
      }
    });
    buffer.write('  ${safeName(variant)}: ');
    _genMap(buffer, 4, object.map((key, value) => MapEntry(key, value)));
    buffer.write(',\n');
  }
}

String _generateIndent(int length) {
  final buffer = StringBuffer();
  for (int i = 0; i < length; i++) {
    buffer.write(' ');
  }
  return buffer.toString();
}

void _genMap(StringBuffer buffer, int indent, Map<String, dynamic> map) {
  buffer.write('(\n');
  for (final entry in map.entries) {
    buffer.write('${_generateIndent(indent)}${safeName(entry.key)}: ');
    if (entry.value is List) {
      _genList(buffer, indent + 2, entry.value);
    } else if (entry.value is Map) {
      _genMap(buffer, indent + 2, entry.value);
    } else {
      _genValue(buffer, 0, entry.value);
    }
    buffer.write(',\n');
  }
  buffer.write('${_generateIndent(indent - 2)})');
}

void _genList(StringBuffer buffer, int indent, List<dynamic> list) {
  buffer.write('[\n');
  for (final value in list) {
    buffer.write(_generateIndent(indent));
    if (value is Map) {
      _genMap(
        buffer,
        indent + 2,
        value.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    } else if (value is List) {
      _genList(buffer, indent + 2, value);
    } else {
      _genValue(buffer, 0, value);
    }
    buffer.write(',\n');
  }
  buffer.write('${_generateIndent(indent - 2)}]');
}

void _genValue(StringBuffer buffer, int indent, dynamic value) {
  buffer.write('${_generateIndent(indent)}$value');
}