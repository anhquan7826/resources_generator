import 'package:resources_generator/util/dart_keywords.dart';

String safeName(String name) {
  var trimmed = name
      .trim()
      .replaceAll(RegExp(r'\W'), '_')
      .replaceAll(RegExp('_{2,}'), '_');
  if (dartKeywords.contains(trimmed)) {
    trimmed = '$trimmed\$';
  }
  return trimmed;
}
