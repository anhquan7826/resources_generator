import 'dart:io';

import 'package:path/path.dart';
import 'package:resources_generator/generators/color_generator.dart';
import 'package:resources_generator/generators/config_generator.dart';
import 'package:resources_generator/generators/font_generator.dart';
import 'package:resources_generator/generators/image_generator.dart';
import 'package:resources_generator/generators/pubspec_generator.dart';
import 'package:resources_generator/generators/raw_generator.dart';
import 'package:resources_generator/generators/root_generator.dart';
import 'package:resources_generator/generators/script_generator.dart';
import 'package:resources_generator/generators/string_generator.dart';
import 'package:resources_generator/generators/value_generator.dart';
import 'package:resources_generator/generators/vector_generator.dart';
import 'package:resources_generator/util/arguments.dart';
import 'package:resources_generator/util/constants.dart';
import 'package:resources_generator/util/extensions/file_ext.dart';
import 'package:resources_generator/util/logger.dart';

void generateWithFlavors(Arguments arguments) {
  assert(
    Directory(join(arguments.assetsLocation, flavorDefault)).existsSync(),
    'Flavored assets must have a default assets folder "all/"!',
  );
  Directory(arguments.assetsLocation)
      .listSync()
      .whereType<Directory>()
      .forEach((flavorDir) {
    final flavor = basename(flavorDir.unixPath);
    Logger.verboseLog('Generating flavor $flavor...');
    generateVectorResources(
      input: join(arguments.assetsLocation, flavor, 'vectors'),
      output: arguments.outputLocation,
      package: arguments.package,
      flavor: flavor,
    );
    generateImageResources(
      input: join(arguments.assetsLocation, flavor, 'images'),
      output: arguments.outputLocation,
      package: arguments.package,
      flavor: flavor,
    );
    generateFontResources(
      input: join(arguments.assetsLocation, flavor, 'fonts'),
      output: arguments.outputLocation,
      package: arguments.package,
      flavor: flavor,
    );
    generateScriptResources(
      input: join(arguments.assetsLocation, flavor, 'scripts'),
      output: arguments.outputLocation,
      package: arguments.package,
      flavor: flavor,
    );
    generateColorResources(
      input: join(arguments.assetsLocation, flavor, 'colors'),
      output: arguments.outputLocation,
      flavor: flavor,
    );
    generateStringResources(
      input: join(arguments.assetsLocation, flavor, 'translations'),
      output: arguments.outputLocation,
      flavor: flavor,
    );
    generateConfigResources(
      input: join(arguments.assetsLocation, flavor, 'configs'),
      output: arguments.outputLocation,
      flavor: flavor,
    );
    generateValueResources(
      input: join(arguments.assetsLocation, flavor, 'values'),
      output: arguments.outputLocation,
      flavor: flavor,
    );
    generateRawResources(
      input: join(arguments.assetsLocation, flavor, 'raws'),
      output: arguments.outputLocation,
      flavor: flavor,
    );
    generateRootResourcesWithFlavor(
      output: arguments.outputLocation,
    );
    Logger.verboseLog('Flavor $flavor generated!');
  });
  declarePubspecAssets(
    arguments.assetsLocation,
    hasFlavors: true,
  );
}

void generate(Arguments arguments) {
  generateVectorResources(
    input: join(arguments.assetsLocation, 'vectors'),
    output: arguments.outputLocation,
    package: arguments.package,
  );
  generateImageResources(
    input: join(arguments.assetsLocation, 'images'),
    output: arguments.outputLocation,
    package: arguments.package,
  );
  generateFontResources(
    input: join(arguments.assetsLocation, 'fonts'),
    output: arguments.outputLocation,
    package: arguments.package,
  );
  generateScriptResources(
    input: join(arguments.assetsLocation, 'scripts'),
    output: arguments.outputLocation,
    package: arguments.package,
  );
  generateColorResources(
    input: join(arguments.assetsLocation, 'colors'),
    output: arguments.outputLocation,
  );
  generateStringResources(
    input: join(arguments.assetsLocation, 'translations'),
    output: arguments.outputLocation,
  );
  generateConfigResources(
    input: join(arguments.assetsLocation, 'configs'),
    output: arguments.outputLocation,
  );
  generateValueResources(
    input: join(arguments.assetsLocation, 'values'),
    output: arguments.outputLocation,
  );
  generateRawResources(
    input: join(arguments.assetsLocation, 'raws'),
    output: arguments.outputLocation,
  );
  generateRootResources(
    output: arguments.outputLocation,
  );
  declarePubspecAssets(
    arguments.assetsLocation,
    hasFlavors: false,
  );
}
