import 'package:yaml_edit/yaml_edit.dart';

extension YamlEditorExtension on YamlEditor {
  void appendToMap(Iterable<String> path, String key, Object? value) {
    final currentValue = parseAt(path).value;
    if (currentValue is! Map?) {
      return;
    }
    update(path, {
      ...?currentValue,
      key: value,
    });
  }
}