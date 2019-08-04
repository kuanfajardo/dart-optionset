# OptionSet

A Dart package for working with option sets (i.e. bitmasks).

## Example
```dart
@option_set
enum _ImageFormat { png, jpeg, svg, gif }

// Easy to read construction
ImageFormat acceptedFormats = ImageFormat.png & ImageFormat.jpeg;
print(acceptedFormats); // ImageFormat (0011): png, jpeg

// Querying
acceptedFormats.has(ImageFormat.png); // true
acceptedFormats.has(ImageFormat.gif); // false

// Negation
ImageFormat nonAcceptedFormats = ~acceptedFormats;

// ... and more!
```

## Installation
See [TODO] on how to install dart packages.

## Usage
### Creating an OptionSet

#### Automatic using `build_runner`
```dart
@option_set
enum _ImageFormat {
  png,
  jpeg,
  svg,
  gif
}
```

See [Automatic Generation](#Auto-generation-of-OptionSet) for how to
setup auto-generation of option sets!

#### Manual
```dart
class ImageFormat extends OptionSet<ImageFormat> { // (1)
  const ImageFormat._(rawValue) : super(rawValue); // (2)

  // OPTIONS //
  static final png = const ImageFormat._(1 << 0); // (3)
  static final jpeg = const ImageFormat._(1 << 1);
  static final svg = const ImageFormat._(1 << 2);
  static final gif = const ImageFormat._(1 << 3);

  // COMPOUND OPTIONS
  static final rasters = png & jpeg;
  
  // CONVENIENCE OPTIONS
  static final none = const ImageFormat._(0); // (4)
  static final all = png & jpeg & svg & gif;
  
  @override
  final List<String> optionNames = const [ // (5)
    'png', 'jpeg', 'svg', 'gif'
  ];

  @override
  ImageFormat initWithRawValue(int rawValue) { // (6)
    return ImageFormat._(rawValue);
  }
}
```
1. Define a new class and extend `OptionSet` with the new class as the
   type parameter for OptionSet.

2. Implement a `const` constructor (ideally private) that calls the
   `OptionSet` constructor
 
3. Add the options to the class as `static final` values using the
   bitwise shift convention shown in the example.

4. *(Optional)* Define `none` and/or `all` options.

5. Override `optionNames`.

6. Override `initWithRawValue`.

### Using an OptionSet

#### **Construction**
```dart
ImageFormat acceptedFormats = ImageFormat.png;
print(acceptedFormats); // ImageFormat (0001): png

ImageFormat rasterFormats = ImageFormat.png & ImageFormat.jpeg;
print(acceptedFormats); // ImageFormat (0011): png, jpeg
```

#### **Combination**
```dart
acceptedFormats = acceptedFormats & ImageFormat.jpeg;
print(acceptedFormats); // ImageFormat (0011): png, jpeg
```

#### **Negation**
```dart
ImageFormat nonAcceptedFormats = ~acceptedFormats;
print(nonAcceptedFormats); // ImageFormat (1100): svg, gif
```

#### **Querying**
```dart
// Single
bool isSvgAccepted = acceptedFormats.has(ImageFormat.svg);
print(isSvgAccepted); // false

bool isPngAccepted = acceptedFormats.has(ImageFormat.png);
print(isPngAccepted); // true

// Compound
bool areBothSvgAndPngAccepted =
acceptedFormats.has(ImageFormat.svg & ImageFormat.png);
print(areBothSvgAndPngAccepted); // false

bool areBothJpegAndPngAccepted =
acceptedFormats.has(ImageFormat.jpeg & ImageFormat.png);
print(areBothJpegAndPngAccepted); // true
```

#### **Toggling**
```dart
// Single
acceptedFormats.toggle(ImageFormat.gif); 
print(acceptedFormats); // ImageFormat (1011): png, jpeg, gif

// Compound
acceptedFormats = acceptedFormats.toggle(ImageFormat.gif & ImageFormat.svg);
print(acceptedFormats); // ImageFormat (0111): png, jpeg, svg
```

#### **Turn off**
```dart
// Single
acceptedFormats = acceptedFormats.turnOff(ImageFormat.png);
print(acceptedFormats); // ImageFormat (0110): jpeg, svg

// Compound
acceptedFormats = acceptedFormats.turnOff(ImageFormat.jpeg & ImageFormat.svg);
print(acceptedFormats); // ImageFormat (0000):
```

#### **Equality**
```dart
OptionSet otherEmptyOptionSet = OptionSet(0);
print(acceptedFormats.rawValue == otherEmptyOptionSet.rawValue); // true
print(acceptedFormats == otherEmptyOptionSet); // fa

ImageFormat otherEmptyImageFormat = ImageFormat.none;
print(acceptedFormats == otherEmptyImageFormat); // true
```

## Auto-generation of `OptionSet`
To take full advantage of this package, use the `build_runner` package
along with the `@option_set` annotation to auto-generate the boilerplate
code needed to extend `OptionSet`:

**pubspec.yaml** (in project root)
```yaml
dependencies:
  option_set: ^0.0.1

dev_dependencies:
  build_runner: ^1.0.0
  build_verify: ^1.1.0
```

**build.yaml** (in project root)
```yaml
targets:
  $default:
    builders:
      option_set|option_set:
        generate_for:
          - lib/generator_example.dart
```

**lib/generator_example.dart** 
```dart
import 'package:option_set/option_set.dart';
part 'generator_example.g.dart';

@option_set
enum _ImageFormat {
  png,
  jpeg,
  svg,
  gif,
}
```

**Terminal** 
```bash
cd $PROJECT_ROOT
pub run build_runner build
```

### `@option_set` configurations 
If you only need a bare-bones `OptionSet`, then just use the
`@option_set` annotation. However, if you want a more complex
implementation, use the `@Option_Set` annotation!

The `@Option_Set` annotation takes 4 optional parameters:

```dart
@Option_Set((
  String name,
  Map<String, List<Object>> compound,
  bool includeNone,
  bool includeAll,
})

// Example
@Option_Set(
  name: 'USPSShippingOptions',
  compound: {'express': [_ShippingOptions.nextDay, _ShippingOptions.secondDay],},
  includeNone: true,
  includeAll: true
)
enum _ShippingOptions {
  nextDay,
  secondDay,
  priority,
  standard
}
```

#### **name**
Name to use for generated option set. 

If not set, will look at annotated enum name. If the enum name starts
with `_`, the generated option set name will be the enum name minus the
leading `_`. Otherwise, the option set name will be the enum name with
`Options` appended to it.

#### **compound**
`Map` of compound option names to a list of the enum values to use to
construct the compound option.

Example: 

`compound: {'rasters: [_ImageFormat.png, _ImageFormat.jpeg]}`

#### **includeNone**
If true, will generate a `none` option. Defaults to `false`.

#### **includeAll**
If true, will generate an `all` option. Defaults to `false`.