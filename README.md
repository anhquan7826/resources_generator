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
dart pub global run tek_generator:generate -i <assets-folder> -o <output-folder>
```

## Contact

Contact Nguyen Anh Quan (anhquan7826@gmail.com or quan.na@teko.vn) for more information or requests.