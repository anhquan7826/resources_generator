import 'package:resources_generator/util/filename_util.dart';

class Writer {
  Writer(this.buffer);

  final StringBuffer buffer;

  void writeRecord(
    int indent,
    Map<String, dynamic> map, {
    /// If `recursive` is `true`, a `Map` will be converted into a `Record`, and
    /// its `Map` values will be converted as well. Otherwise, they will be written
    /// as a literal `Map`.
    bool recursive = true,

    /// If `true`, `String` will be treated as a generic value, thus no quote characters
    /// will be written.
    bool stringAsAny = false,
  }) {
    buffer.write('(\n');
    for (final entry in map.entries) {
      buffer.write('${_generateIndent(indent)}${safeName(entry.key)}: ');
      if (entry.value is List) {
        writeList(
          indent + 2,
          entry.value,
          stringAsAny: stringAsAny,
        );
      } else if (entry.value is Map) {
        if (recursive) {
          writeRecord(
            indent + 2,
            entry.value,
            stringAsAny: stringAsAny,
          );
        } else {
          writeMap(
            indent + 2,
            entry.value,
            stringAsAny: stringAsAny,
          );
        }
      } else if (stringAsAny) {
        writeAny(0, entry.value);
      } else {
        if (entry.value is String) {
          writeString(0, entry.value);
        } else {
          writeAny(0, entry.value);
        }
      }
      buffer.write(',\n');
    }
    buffer.write('${_generateIndent(indent - 2)})');
  }

  void writeMap(
    int indent,
    Map<String, dynamic> map, {
    /// If `true`, `String` will be treated as a generic value, thus no quote characters
    /// will be written.
    bool stringAsAny = false,
  }) {
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
        writeList(
          indent + 2,
          entry.value,
          stringAsAny: stringAsAny,
        );
      } else if (entry.value is Map) {
        writeMap(
          indent + 2,
          entry.value,
          stringAsAny: stringAsAny,
        );
      } else if (stringAsAny) {
        writeAny(0, entry.value);
      } else {
        if (entry.value is String) {
          writeString(0, entry.value);
        } else {
          writeAny(0, entry.value);
        }
      }
      buffer.write(',\n');
    }
    buffer.write('${_generateIndent(indent - 2)}}');
  }

  void writeList(
    int indent,
    List<dynamic> list, {
    /// If `true`, `String` will be treated as a generic value, thus no quote characters
    /// will be written.
    bool stringAsAny = false,
  }) {
    buffer.write('[\n');
    for (final value in list) {
      buffer.write(_generateIndent(indent));
      if (value is Map) {
        writeMap(
          indent + 2,
          value.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
          stringAsAny: stringAsAny,
        );
      } else if (value is List) {
        writeList(
          indent + 2,
          value,
          stringAsAny: stringAsAny,
        );
      } else if (stringAsAny) {
        writeAny(0, value);
      } else {
        if (value is String) {
          writeString(0, value);
        } else {
          writeAny(0, value);
        }
      }
      buffer.write(',\n');
    }
    buffer.write('${_generateIndent(indent - 2)}]');
  }

  void writeString(int indent, String string) {
    string = string
        .replaceAll("'", r"\'")
        .replaceAll('"', r'\"')
        .replaceAll(r'$', r'\$');
    buffer.write(
      "${_generateIndent(indent)}'$string'",
    );
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
