import 'dart:async';
import 'dart:io';

import 'package:resources_generator/process.dart';
import 'package:resources_generator/util/arguments.dart';
import 'package:resources_generator/util/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watcher/watcher.dart';

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
  final monitorSubscription = _monitorFileSystem(arguments.assetsLocation, () {
    Logger.log('Assets folder changed! Generating...');
    _generate(arguments);
    Logger.log('Resources generated!');
  });
  _monitorProcessSignal(() {
    monitorSubscription.cancel();
    Logger.log('Generator finished!');
    exit(0);
  });
  _generate(arguments);
}

void _generate(Arguments arguments) {
  if (arguments.withFlavors) {
    generateWithFlavors(arguments, isMonitoring: true);
  } else {
    generate(arguments, isMonitoring: true);
  }
}

StreamSubscription _monitorFileSystem(String path, void Function() onChange) {
  const delay = Duration(seconds: 1);
  return DirectoryWatcher(path, pollingDelay: delay)
      .events
      .debounceTime(delay)
      .listen((_) {
    onChange();
  });
}

void _monitorProcessSignal(void Function() onSignal) {
  ProcessSignal.sigint.watch().listen((_) {
    onSignal();
  });
  ProcessSignal.sigusr1.watch().listen((_) {
    onSignal();
  });
  ProcessSignal.sigusr2.watch().listen((_) {
    onSignal();
  });
}