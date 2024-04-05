# Resource generator

## Features

Generate resource class from assets folder.

## Getting started

Before using this generator, your assets folder must have this structure:<br>
```
<your-project>
├── <assets-folder>/
   ├── images/ (for images)
   ├── vectors/ (for vector images or svg)
   ├── translations/ (for localizations)
├── lib/
├── pubspec.yaml
```

## Usage

Activate executable:<br>
```
dart pub global activate tek_generator
```

`cd` to your ptoject folder:
```
cd <your-project>
```

Run the generator:
```
dart pub global run tek_generator:generate -i <assets-folder> -o <output-folder> -p <optional-package>
```
where:
- `-i`, optional, is the assets folder, default to `assets`.
- `-o`, optional, is the output folder, default to `resources`.
- `-p`, optional, is the package name if assets are in a package/module instead of an application.

## Contact

Contact Nguyen Anh Quan (anhquan7826@gmail.com or quan.na@teko.vn) for more information or requests.