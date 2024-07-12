import 'package:yaml_edit/yaml_edit.dart';

extension YamlEditorExtension on YamlEditor {
  void createEmptyKey(Iterable<String> parent, String key) {
    final currentValue = parseAt(parent) as Map;
    update(parent, {
      ...currentValue,
      key: null,
    });
  }

  void appendToMap(Iterable<String> path, String key, Object? value) {
    Map? currentValue;
    try {
      currentValue = parseAt(path).value as Map;
    } catch (_) {}
    update(path, {
      ...?currentValue,
      key: value,
    });
  }
}