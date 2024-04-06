import 'dart:io';

import 'package:tek_generator/color_generator.dart';
import 'package:tek_generator/font_generator.dart';
import 'package:tek_generator/image_generator.dart';
import 'package:tek_generator/root_generator.dart';
import 'package:tek_generator/script_generator.dart';
import 'package:tek_generator/string_generator.dart';
import 'package:tek_generator/vector_generator.dart';

void main(List<String> args) {
  final arguments = Arguments.read(args);
  if (!Directory(arguments.assetsLocation).existsSync()) {
    throw Exception('Assets location is not exist!');
  }
  generateVectorResources(
    input: '${arguments.assetsLocation}/vectors',
    output: arguments.outputLocation,
    package: arguments.package,
  );
  generateImageResources(
    input: '${arguments.assetsLocation}/images',
    output: arguments.outputLocation,
    package: arguments.package,
  );
  generateFontResources(
    input: '${arguments.assetsLocation}/fonts',
    output: arguments.outputLocation,
    package: arguments.package,
  );
  generateScriptResources(
    input: '${arguments.assetsLocation}/scripts',
    output: arguments.outputLocation,
    package: arguments.package,
  );
  generateColorResources(
    input: '${arguments.assetsLocation}/colors',
    output: arguments.outputLocation,
  );
  generateStringResources(
    input: '${arguments.assetsLocation}/translations',
    output: arguments.outputLocation,
  );
  generateRootResources(
    output: arguments.outputLocation,
  );
}

class Arguments {
  Arguments({
    String assetsLocation = 'assets',
    String outputLocation = 'resources',
    this.package,
  }) {
    this.assetsLocation = assetsLocation.endsWith('/')
        ? assetsLocation.substring(0, assetsLocation.length - 1)
        : assetsLocation;
    this.outputLocation = outputLocation.endsWith('/')
        ? outputLocation.substring(0, outputLocation.length - 1)
        : outputLocation;
  }

  factory Arguments.read(List<String> args) {
    final arguments = _processArguments(args);
    return Arguments(
      assetsLocation: arguments['i']?.first ?? 'assets',
      outputLocation: arguments['o']?.first ?? 'resources',
      package: arguments['p']?.first,
    );
  }

  static Map<String, List<String>> _processArguments(List<String> args) {
    final Map<String, List<String>> result = {};
    int i = 0;
    while (i < args.length) {
      final arg = args[i];
      if (arg.startsWith('-')) {
        final flags = <String>[];
        int j = i + 1;
        while (j < args.length && !args[j].startsWith('-')) {
          final flag = args[j];
          flags.add(flag);
          j++;
        }
        result[arg.substring(1)] = flags;
        i = j;
      } else {
        throw Exception("Invalid argument: '$arg' at index $i!");
      }
    }
    result.forEach((key, value) {
      if (value.isEmpty) {
        throw Exception("Invalid argument: Empty flag for argument '-$key'!");
      }
    });
    return result;
  }

  late final String assetsLocation;
  late final String outputLocation;
  late final String? package;
}
