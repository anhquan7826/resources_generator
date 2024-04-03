import 'dart:io';

import 'package:tek_generator/image_generator.dart';
import 'package:tek_generator/root_generator.dart';
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
  );
  generateImageResources(
    input: '${arguments.assetsLocation}/images',
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
  }) {
    this.assetsLocation = assetsLocation.endsWith('/')
        ? assetsLocation.substring(0, assetsLocation.length - 1)
        : assetsLocation;
    this.outputLocation = outputLocation.endsWith('/')
        ? outputLocation.substring(0, outputLocation.length - 1)
        : outputLocation;
  }

  factory Arguments.read(List<String> args) {
    if (args.length % 2 != 0) {
      throw ArgumentError('Invalid argument!');
    }
    var i = 0;
    String assets = 'assets';
    String output = 'resources';
    while (i < args.length) {
      switch (args[i]) {
        case '-i':
          assets = args[++i];
          break;
        case '-o':
          output = args[++i];
          break;
      }
      i++;
    }
    return Arguments(
      assetsLocation: assets,
      outputLocation: output,
    );
  }

  late final String assetsLocation;
  late final String outputLocation;
}
