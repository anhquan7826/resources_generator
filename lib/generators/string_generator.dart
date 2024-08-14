import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/extensions/object.ext.dart';
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
  final buffer = StringBuffer();
  _writeStart(buffer, flavor);
  try {
    final file = directory.listSync().firstWhere(
      (element) {
        return element is File &&
            extension(element.unixPath) == '.json' &&
            !element.isHidden;
      },
    ) as File;
    final line = file.readAsStringSync();
    final map = (json.decode(line) as Map).map((key, value) {
      return MapEntry(key.toString(), value);
    });
    _recurse(buffer, 2, map);
  } catch (_) {
    Logger.log('Invalid string resources detected!');
    Logger.verboseLog(_);
  }
  _writeFinish(buffer);
  Directory(join(output, flavor)).createSync(recursive: true);
  File(joinAll([output, flavor, 'string_resources.dart'].whereType<String>()))
    ..createSync()
    ..writeAsStringSync(buffer.toString());
  Logger.verboseLog('Generated string resources!');
}

void _writeStart(StringBuffer buffer, String? flavor) {
  buffer.writeln("""
// ignore_for_file: non_constant_identifier_names, constant_identifier_names
part of '${flavor == null ? '' : '../'}resources.dart';

const _${flavor == null ? '' : '${flavor}_'}string_resources = (""");
}

void _writeFinish(StringBuffer buffer) {
  buffer.writeln(');');
}

void _recurse(
  StringBuffer buffer,
  int indent,
  Map<String, dynamic> map, [
  String prefix = '',
]) {
  final entries = map.entries.sortedBy((e) => e.key);
  for (final entry in entries) {
    if (entry.value is String) {
      _writeEntry(
        buffer,
        indent,
        entry.cast(),
        prefix,
      );
    } else if (entry.value is Map) {
      if (_isSpecial(entry.value)) {
        _writeEntry(
          buffer,
          indent,
          entry.cast(),
          prefix,
        );
      } else {
        buffer.writeln('${_generateIndent(indent)}${safeName(entry.key)}: (');
        _recurse(
          buffer,
          indent + 2,
          entry.value,
          _joinPrefix(prefix, entry.key),
        );
        buffer.write('${_generateIndent(indent)}),');
      }
    }
    buffer.writeln();
  }
}

void _writeEntry(
  StringBuffer buffer,
  int indent,
  MapEntry<String, dynamic> entry, [
  String prefix = '',
]) {
  final key = safeNameTr(_joinPrefix(prefix, entry.key));
  buffer.write(
    '${_generateIndent(indent)}${safeName(entry.key)}: "$key",',
  );
}

String _generateIndent(int length) {
  final result = StringBuffer();
  for (int i = 0; i < length; i++) {
    result.write(' ');
  }
  return result.toString();
}

String _joinPrefix(String prefix, String value) {
  if (prefix.isEmpty) {
    return value;
  }
  return '$prefix.$value';
}

// Whether this entry is plural or gender-based translation.
// Complying with easy_localization plural rules.
bool _isSpecial(Map<String, dynamic> values) {
  final pluralRules = {
    'zero',
    'one',
    'two',
    'few',
    'many',
    'other',
  };
  final genderRules = {
    'male',
    'female',
    'other',
  };
  final containPlurals = values.keys.every(
    (e) => pluralRules.contains(e),
  );
  final containGender = values.keys.every(
    (e) => genderRules.contains(e),
  );
  return containPlurals ^ containGender;
}
