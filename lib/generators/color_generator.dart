import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/extensions/scope_ext.dart';
import 'package:resources_generator/util/filename_util.dart';
import 'package:resources_generator/util/logger.dart';
import 'package:resources_generator/util/sort_algorithm.dart';
import 'package:resources_generator/util/writer.dart';

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
    final files = directory
        .listSync()
        .where((fs) {
          return fs is File &&
              extension(fs.unixPath) == '.json' &&
              !fs.isHidden &&
              basenameWithoutExtension(fs.unixPath).startsWith('colors');
        })
        .cast<File>()
        .toList()
      ..sort(sortFilesByName);
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

final _hexMatch = RegExp('0x[0-9A-Fa-f]{8}');

List<dynamic> _filterList(List list) {
  final result = [];
  for (final e in list) {
    if (e is Map) {
      result.add(_filterMap(e));
    } else if (e is List) {
      result.add(_filterList(e));
    } else if (e is String) {
      if (_hexMatch.hasMatch(e)) {
        result.add(e);
      }
    }
  }
  return result;
}

Map<String, dynamic> _filterMap(Map map) {
  final Map<String, dynamic> result = {};
  for (final entry in map.entries) {
    if (entry.value is Map) {
      result[entry.key] = _filterMap(entry.value);
    } else if (entry.value is List) {
      result[entry.key] = _filterList(entry.value);
    } else if (entry.value is String) {
      if (_hexMatch.hasMatch(entry.value)) {
        result[entry.key] = entry.value;
      }
    }
  }
  return result;
}

void _writeColorsSingle(File file, StringBuffer buffer) {
  final line = file.readAsStringSync();
  var object = json.decode(line);
  if (object is Map) {
    object = _filterMap(object);
    for (final entry in object.entries) {
      if (entry.value.toString().isEmpty) {
        continue;
      }
      buffer.write('  ${safeName(entry.key)}: ');
      if (entry.value is Map) {
        Writer(buffer).writeRecord(4, entry.value, stringAsAny: true);
      } else if (entry.value is List) {
        Writer(buffer).writeList(4, entry.value, stringAsAny: true);
      } else {
        Writer(buffer).writeAny(0, entry.value);
      }
      buffer.write(',\n');
    }
  }
}

void _writeColorsMultiple(Iterable<File> files, StringBuffer buffer) {
  for (final file in files) {
    final line = file.readAsStringSync();
    var object = json.decode(line);
    if (object is! Map) {
      continue;
    }
    object = _filterMap(object);
    final variant = basenameWithoutExtension(file.unixPath).let((it) {
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
    Writer(buffer).writeRecord(
      4,
      object.map((key, value) => MapEntry(key, value)),
      stringAsAny: true,
    );
    buffer.write(',\n');
  }
}
