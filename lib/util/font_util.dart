import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';

final _fontStyles = {
  'italic',
};
final _fontWeights = List.generate(8, (i) => (i + 1) * 100).toSet();

typedef _FontAttributes = ({
  String asset,
  String? style,
  int? weight,
});

class FontAsset {
  FontAsset({
    required this.family,
    List<String> assets = const [],
    this.flavor,
  }) {
    fonts = assets.map((asset) {
      final attrs = _getAttributes(asset);
      return (
        asset: asset,
        style: attrs?.firstWhereOrNull((attr) {
              return _fontStyles.contains(attr);
            }),
        weight: () {
              final attr = attrs?.firstWhereOrNull((element) {
                return RegExp(r'^w\d{3}$').hasMatch(element);
              });
              if (attr == null) {
                return null;
              }
              return int.parse(attr.replaceAll('w', ''));
            }(),
      );
    }).toList();
  }

  final String family;
  late final List<_FontAttributes> fonts;
  final String? flavor;

  List<String>? _getAttributes(String asset) {
    try {
      final attrs = basenameWithoutExtension(asset)
          .split('-')
          .sublist(1)
          .map((e) => e.toLowerCase());
      final filtered = attrs.where((element) {
        return _fontStyles.contains(element) ||
            _fontWeights.contains(int.parse(element.replaceFirst('w', '')));
      });
      if (filtered.isEmpty) {
        return null;
      }
      return filtered.toList();
    } catch (_) {
      return null;
    }
  }
}

List<FontAsset> getFontsAttributes(
  String fontsPath, {
  String? flavor,
}) {
  final dir = Directory(fontsPath);
  if (!dir.existsSync()) {
    return [];
  }
  final files = dir.listSync().where((element) {
    return element is File &&
        ['.ttc', '.ttf', '.otf'].contains(extension(element.unixPath));
  });
  final grouped = groupBy(files, (s) {
    final parts = basenameWithoutExtension(s.unixPath).split('-');
    return parts.first;
  });
  return grouped.entries.map((e) {
    final family = e.key;
    return FontAsset(
      family: family,
      assets: e.value.map((f) => f.unixPath).toList(),
      flavor: flavor,
    );
  }).sortedBy((e) => e.family);
}
