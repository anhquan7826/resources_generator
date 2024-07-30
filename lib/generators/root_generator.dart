import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/util/constants.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/sort_algorithm.dart';

void generateRootResources({required String output}) {
  final directory = Directory(output);
  final buffer = StringBuffer();
  final files = directory
      .listSync()
      .map((e) {
        if (e is File) {
          if (extension(e.unixPath) == '.dart' &&
              basename(e.unixPath) != 'resources.dart') {
            return e;
          }
        }
      })
      .whereType<File>()
      .toList()
    ..sort(
      sortFilesByName,
    );
  for (final file in files) {
    buffer.writeln("part '${basename(file.unixPath)}';");
  }
  buffer.writeln('''

class R {
  R._();
''');
  for (final file in files) {
    switch (basenameWithoutExtension(file.unixPath)) {
      case 'string_resources':
        buffer.writeln('  static const strings = _string_resources;');
        break;
      case 'image_resources':
        buffer.writeln('  static const images = _image_resources;');
        break;
      case 'vector_resources':
        buffer.writeln('  static const vectors = _vector_resources;');
        break;
      case 'font_resources':
        buffer.writeln('  static const fonts = _font_resources;');
        break;
      case 'script_resources':
        buffer.writeln('  static const scripts = _script_resources;');
        break;
      case 'color_resources':
        buffer.writeln('  static const colors = _color_resources;');
        break;
      case 'config_resources':
        buffer.writeln('  static const configs = _config_resources;');
        break;
      case 'value_resources':
        buffer.writeln('  static const values = _value_resources;');
        break;
      case 'raw_resources':
        buffer.writeln('  static const raws = _raw_resources;');
        break;
    }
  }
  buffer.writeln('}');
  Directory(output).createSync(recursive: true);
  File('$output/resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
}

void generateRootResourcesWithFlavor({required String output}) {
  final directory = Directory(output);
  final buffer = StringBuffer();

  void forEachFileInFlavors(
    Directory rootDir, {
    void Function(Directory flavor)? flavorStartCallback,
    void Function(Directory flavor, File file)? fileCallback,
    void Function(Directory flavor)? flavorEndCallback,
  }) {
    final flavors = directory.listSync().whereType<Directory>().toList()
      ..sort((a, b) {
        final baseA = basename(a.unixPath);
        final baseB = basename(b.unixPath);
        if (baseA == flavorDefault) {
          return -1;
        }
        if (baseB == flavorDefault) {
          return 1;
        }
        return baseA.compareTo(baseB);
      });
    for (final flavor in flavors) {
      flavorStartCallback?.call(flavor);
      final files = flavor
          .listSync()
          .where((element) {
            return element is File && extension(element.unixPath) == '.dart';
          })
          .cast<File>()
          .toList()
        ..sort(
          sortFilesByName,
        );
      for (final file in files) {
        fileCallback?.call(flavor, file);
      }
      flavorEndCallback?.call(flavor);
    }
  }

  forEachFileInFlavors(
    directory,
    fileCallback: (flavor, file) {
      buffer.writeln("part '${basename(flavor.unixPath)}/${basename(file.unixPath)}';");
    },
    flavorEndCallback: (flavor) {
      buffer.writeln();
    },
  );
  buffer.writeln('''
class R {
  R._();''');
  forEachFileInFlavors(
    directory,
    flavorStartCallback: (flavor) {
      buffer.writeln('\n  static const ${basename(flavor.unixPath)} = (');
    },
    fileCallback: (flavor, file) {
      final flavorName = basename(flavor.unixPath);
      switch (basenameWithoutExtension(file.unixPath)) {
        case 'string_resources':
          buffer.writeln('    strings: _${flavorName}_string_resources,');
          break;
        case 'image_resources':
          buffer.writeln('    images: _${flavorName}_image_resources,');
          break;
        case 'vector_resources':
          buffer.writeln('    vectors: _${flavorName}_vector_resources,');
          break;
        case 'font_resources':
          buffer.writeln('    fonts: _${flavorName}_font_resources,');
          break;
        case 'script_resources':
          buffer.writeln('    scripts: _${flavorName}_script_resources,');
          break;
        case 'color_resources':
          buffer.writeln('    colors: _${flavorName}_color_resources,');
          break;
        case 'config_resources':
          buffer.writeln('    configs: _${flavorName}_config_resources,');
          break;
        case 'value_resources':
          buffer.writeln('    values: _${flavorName}_value_resources,');
          break;
        case 'raw_resources':
          buffer.writeln('    raws: _${flavorName}_raw_resources,');
          break;
      }
    },
    flavorEndCallback: (flavor) {
      buffer.writeln('  );');
    },
  );
  buffer.writeln('}');
  Directory(output).createSync(recursive: true);
  File('$output/resources.dart')
    ..createSync()
    ..writeAsStringSync(buffer.toString());
}
