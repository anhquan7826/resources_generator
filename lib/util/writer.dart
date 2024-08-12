import 'package:resources_generator/util/filename_util.dart';

class Writer {
  Writer(this.buffer);

  final StringBuffer buffer;

  void writeRecord(
    int indent,
    Map<String, dynamic> map, {
    bool recursive = true,
  }) {
    buffer.write('(\n');
    for (final entry in map.entries) {
      buffer.write('${_generateIndent(indent)}${safeName(entry.key)}: ');
      if (entry.value is List) {
        writeList(indent + 2, entry.value);
      } else if (entry.value is Map) {
        if (recursive) {
          writeRecord(indent + 2, entry.value);
        } else {
          writeMap(indent + 2, entry.value);
        }
      } else if (entry.value is String) {
        writeString(0, entry.value);
      } else {
        writeAny(0, entry.value);
      }
      buffer.write(',\n');
    }
    buffer.write('${_generateIndent(indent - 2)})');
  }

  void writeMap(int indent, Map<String, dynamic> map) {
    buffer.write('{\n');
    for (final entry in map.entries) {
      if (entry.key.contains("'")) {
        buffer.write(
          '${_generateIndent(indent)}"${entry.key}": ',
        );
      } else {
        buffer.write(
          "${_generateIndent(indent)}'${entry.key}': ",
        );
      }
      if (entry.value is List) {
        writeList(indent + 2, entry.value);
      } else if (entry.value is Map) {
        writeMap(indent + 2, entry.value);
      } else if (entry.value is String) {
        writeString(0, entry.value);
      } else {
        writeAny(0, entry.value);
      }
      buffer.write(',\n');
    }
    buffer.write('${_generateIndent(indent - 2)}}');
  }

  void writeList(int indent, List<dynamic> list) {
    buffer.write('[\n');
    for (final value in list) {
      buffer.write(_generateIndent(indent));
      if (value is Map) {
        writeMap(
          indent + 2,
          value.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
      } else if (value is List) {
        writeList(indent + 2, value);
      } else if (value is String) {
        writeString(0, value);
      } else {
        writeAny(0, value);
      }
      buffer.write(',\n');
    }
    buffer.write('${_generateIndent(indent - 2)}]');
  }

  void writeString(int indent, String string) {
    if (string.contains("'")) {
      buffer.write(
        '${_generateIndent(indent)}"$string"',
      );
    } else {
      buffer.write(
        "${_generateIndent(indent)}'$string'",
      );
    }
  }

  void writeAny(int indent, dynamic value) {
    buffer.write('${_generateIndent(indent)}$value');
  }

  String _generateIndent(int length) {
    final result = StringBuffer();
    for (int i = 0; i < length; i++) {
      result.write(' ');
    }
    return result.toString();
  }
}
