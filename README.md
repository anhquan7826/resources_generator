# Resource generator

## Feature

Generate a resource class from `assets/` folder, similar to `R` class on Android.

## Configurations

This generator supports generate common assets folder and assets folder divided by flavors.

### Without flavor

Required structure for assets folder:

```
<your-project>
├── <assets-folder>/
   ├── images/ (for images)
   ├── vectors/ (for vector images or svg)
   ├── translations/ (for localizations)
   ├── fonts/ (for fonts)
   ├── scripts/ (for shell scripts)
   ├── configs/ (for JSON configurations)
   ├── raws/ (for raw files)
├── lib/
├── pubspec.yaml
```

### With flavor

Required structure for assets folder:

```
<your-project>
├── <assets-folder>/
   ├── all/ <common for all flavors>
      ├── images/ (for images)
      ├── vectors/ (for vector images or svg)
      ├── translations/ (for localizations)
      ├── fonts/ (for fonts)
      ├── scripts/ (for shell scripts)
      ├── configs/ (for JSON configurations)
      ├── raws/ (for raw files)
   ├── <flavor-0>
      ├── ... (same as all/)
   ├── <flavor-1>
      ├── ... (same as all/)
   ├── <flavor-2>
      ├── ... (same as all/)
   ├── ...
├── lib/
├── pubspec.yaml
```

## Usage

Activate the executable:
```
dart pub global activate resources_generator
```

`cd` into project root:
```
cd <your-project>
```

Execute the generator:
```
dart pub global run resources_generator:generate -i <assets-folder> -o <output-folder> -p <optional-package> -f
```
with:
- `-i` or `--input`, optional, is the input assets folder, default to `assets`.
- `-o` or `--output`, optional, is the output folder, default to `lib/resources`.
- `-p` or `--package`, optional, is the package name if assets is in a package/module instead of an application..
- `-f` or `--with-flavor`, optional, will generate the resource class into flavors.

## Note

- For generating fonts, font file names must have this format: `<family>-<attr-1>-<attr-2>.ttf`, with attrs to be font style and font weight. These attrs are optional.<br>
Example: Roboto.ttf, Roboto-Italic.ttf, Roboto-Italic-w600.ttf

- For generating colors, all json files must have `colors` as file name prefix. Based on the numbers of file with this prefix, the generator will generate the suitable resource file.<br>
Example:
   - For single file:<br>
      ```
      ├── <assets-folder>/
         ├── colors/
            ├── colors.json
      ```
   - For multiple files (multi variants colors):<br>
      ```
      ├── <assets-folder>/
         ├── colors/
            ├── colors_dark.json
            ├── colors_light.json
      ```