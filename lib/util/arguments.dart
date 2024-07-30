import 'dart:io';

import 'package:resources_generator/util/logger.dart';

enum _ArgTypes {
  input('input', 'i'),
  output('output', 'o'),
  package('package', 'p'),
  withFlavor('with-flavor', 'f'),
  verbose('verbose', 'v');

  const _ArgTypes(this.full, this.short);

  factory _ArgTypes.fromArg(String arg) {
    arg = arg.replaceFirst(RegExp('^(-{1,2})'), '');
    if (arg == input.full || arg == input.short) {
      return _ArgTypes.input;
    }
    if (arg == output.full || arg == output.short) {
      return _ArgTypes.output;
    }
    if (arg == package.full || arg == package.short) {
      return _ArgTypes.package;
    }
    if (arg == withFlavor.full || arg == withFlavor.short) {
      return _ArgTypes.withFlavor;
    }
    if (arg == verbose.full || arg == verbose.short) {
      return _ArgTypes.verbose;
    }
    throw UnimplementedError();
  }

  final String full;
  final String short;
}

class Arguments {
  Arguments._({
    this.assetsLocation = 'assets',
    this.outputLocation = 'lib/resources',
    this.package,
    this.withFlavors = false,
    this.verbose = false,
  });

  factory Arguments.read(List<String> args) {
    final arguments = _processArguments(args);
    return Arguments._(
      assetsLocation: arguments[_ArgTypes.input]?.first ?? 'assets',
      outputLocation: arguments[_ArgTypes.output]?.first ?? 'lib/resources',
      package: arguments[_ArgTypes.package]?.first.replaceAll('/', ''),
      withFlavors: arguments[_ArgTypes.withFlavor] != null,
      verbose: arguments[_ArgTypes.verbose] != null,
    );
  }

  static Map<_ArgTypes, List<String>> _processArguments(List<String> args) {
    final Map<_ArgTypes, List<String>> result = {};
    int i = 0;
    try {
      while (i < args.length) {
        final arg = args[i];
        if (RegExp('^(-{1,2})').hasMatch(arg)) {
          final argType = _ArgTypes.fromArg(arg);
          switch (argType) {
            case _ArgTypes.input:
            case _ArgTypes.output:
            case _ArgTypes.package:
              if (i + 1 >= args.length || args[i + 1].startsWith('-')) {
                throw Exception("Missing value for argument: '$arg'!");
              } else {
                result[argType] = [args[i + 1]];
                i += 2;
              }
              break;
            case _ArgTypes.withFlavor:
            case _ArgTypes.verbose:
              result[argType] = [];
              i++;
              break;
          }
        } else {
          throw Exception("Invalid argument: '$arg' at index $i!");
        }
      }
    } catch (e) {
      Logger.log(e);
      exit(1);
    }
    return result;
  }

  final String assetsLocation;
  final String outputLocation;
  final String? package;
  final bool withFlavors;
  final bool verbose;
}
