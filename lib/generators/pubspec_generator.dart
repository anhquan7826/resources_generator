import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:resources_generator/util/constants.dart';
import 'package:resources_generator/util/extensions/yaml_editor_ext.dart';
import 'package:resources_generator/util/font_util.dart';
import 'package:resources_generator/util/logger.dart';
import 'package:yaml_edit/yaml_edit.dart';

void declarePubspecAssets(
  String assetsPath, {
  required bool hasFlavors,
}) {
  Logger.verboseLog('Updating pubspec.yaml...');
  final pubspec = File('pubspec.yaml');
  final editor = YamlEditor(
    pubspec.readAsStringSync(),
  );
  if (hasFlavors) {
    // Sắp xếp thư mục theo tên flavor. Thư mục assets chung sẽ đặt đầu tiên.
    final flavorDirs =
        Directory(assetsPath).listSync().whereType<Directory>().toList()
          ..sort(
            (a, b) {
              if (basename(a.path) == flavorDefault) {
                return -1;
              }
              if (basename(b.path) == flavorDefault) {
                return 1;
              }
              return basename(a.path).compareTo(basename(b.path));
            },
          );
    // Lấy ra các font trong tất cả các flavor để khai báo.
    final fonts = flavorDirs.map((dir) {
      final flavor = basename(dir.path);
      try {
        final assets = getFontsAttributes(
          join(dir.path, 'fonts'),
          flavor: flavor == flavorDefault ? null : flavor,
        );
        return assets;
      } catch (_) {
        Logger.log(
          'Invalid font names detected at $flavor flavor! Manual fonts declaration in pubspec.yaml is needed!',
        );
        return <FontAsset>[];
      }
    }).toList()
      ..removeWhere((element) => element.isEmpty);
    editor.appendToMap(
      ['flutter'],
      'assets',
      flavorDirs
          .map((flavorDir) {
            final flavor = basename(flavorDir.path);
            return flavorDir
                .listSync()
                .where((e) {
                  return e is Directory &&
                      supportedFolders.contains(basename(e.path));
                })
                .sortedBy((subfolder) => basename(subfolder.path))
                .map((subfolder) {
                  if (flavor == flavorDefault) {
                    return '${subfolder.path}/';
                  } else {
                    return {
                      'path': '${subfolder.path}/',
                      'flavors': [flavor],
                    };
                  }
                });
          })
          .expand((e) => e)
          .toList(),
    );
    if (fonts.isNotEmpty) {
      editor.appendToMap(
        ['flutter'],
        'fonts',
        fonts.expand((element) => element).map((e) {
          return {
            'family': e.family,
            'fonts': e.fonts.map((e) {
              return {
                'asset': e.asset,
                if (e.style != null) 'style': e.style,
                if (e.weight != null) 'weight': e.weight,
              };
            }).toList(),
            if (e.flavor != null) 'flavor': e.flavor,
          };
        }).toList(),
      );
    }
  } else {
    final dirs = Directory(assetsPath).listSync().where((e) {
      return e is Directory && supportedFolders.contains(basename(e.path));
    }).toList()
      ..sortBy((e) => basename(e.path));
    List<FontAsset> fonts = [];
    try {
      fonts = getFontsAttributes(join(assetsPath, 'fonts'));
    } catch (_) {
      Logger.log(
        'Invalid font names detected! Manual fonts declaration in pubspec.yaml is needed!',
      );
    }
    if (dirs.isNotEmpty) {
      editor.appendToMap(
        ['flutter'],
        'assets',
        dirs.map((e) => '${e.path}/').toList(),
      );
    }
    if (fonts.isNotEmpty) {
      editor.appendToMap(
        ['flutter'],
        'fonts',
        fonts.map((assets) {
          return {
            'family': assets.family,
            'fonts': assets.fonts.map((asset) {
              return {
                'asset': asset.asset,
                if (asset.style != null) 'style': asset.style,
                if (asset.weight != null) 'weight': asset.weight,
              };
            }).toList()
          };
        }).toList(),
      );
    }
  }
  pubspec.writeAsStringSync(editor.toString());
  Logger.verboseLog('pubspec.yaml updated!');
}
