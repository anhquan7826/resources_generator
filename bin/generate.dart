import 'dart:io';

import 'package:resources_generator/process.dart';
import 'package:resources_generator/util/arguments.dart';
import 'package:resources_generator/util/logger.dart';

void main(List<String> args) {
  Logger.log('Generator started!');
  final arguments = Arguments.read(args);
  if (!Directory(arguments.assetsLocation).existsSync()) {
    Logger.log('Assets location is not exist!');
    exit(1);
  }
  if (!Directory(arguments.outputLocation).existsSync()) {
    try {
      Directory(arguments.outputLocation).createSync(recursive: true);
    } catch (e) {
      Logger.log('Cannot create output folder!');
      exit(1);
    }
  }
  Logger.verbose = arguments.verbose;
  if (arguments.withFlavors) {
    generateWithFlavors(arguments);
  } else {
    generate(arguments);
  }
  Logger.log('Generator finished!');
}

