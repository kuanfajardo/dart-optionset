/// A wrapper around an integer bitmask used to implement a set of options (i
/// .e. an Option Set).
///
/// This class provides both type safety for option set operations and
/// convenience functions for working with option sets, such as combining,
/// querying, and toggling options.
///
/// This class is meant to be subclassed, To use this class, follow these steps:
///
/// 1. Define a new class and extend [OptionSet] with the new class as
/// the type parameter for OptionSet: `extends OptionSet<$className>`.
/// 2. Implement a `const` constructor (ideally private) that calls the
/// [OptionSet] constructor: `const $className._(rawValue) : super(rawValue);
/// 3. Add the options to the class as `static final` values using
/// the convention shown in the example below.
/// 4. Override [optionNames] and [initWithRawValue].
///
/// Full Example:
///
/// ```dart
/// class ImageFormat extends OptionSet<ImageFormat> {
///   ImageFormat._(rawValue) : super(rawValue);
///
///   // OPTIONS //
///   static final svg = const ImageFormat._(1 << 0);
///   static final jpeg = const ImageFormat._(1 << 1);
///   static final png = const ImageFormat._(1 << 2);
///   static final gif = const ImageFormat._(1 << 3);
///
///   static final rasters = png & jpeg;
///
///   @override
///   final List<String> optionNames = const ['svg', 'jpeg', 'png', 'gif'];
///
///   @override
///   ImageFormat initWithRawValue(int rawValue) {
///     return ImageFormat._(rawValue);
///   }
/// }
/// ```
///
/// Usage:
///
/// ```dart
/// void main() {
///   ImageFormat acceptedFormats = ImageFormat.svg & ImageFormat.png;
///   ImageFormat userPreferenceFormat = ImageFormat.png;
///
///   // Query for single option
///   acceptedFormats.has(userPreferenceFormat); // true
///
///   // Toggle option
///   acceptedFormats = acceptedFormats.toggle(ImageFormat.png);
///
///   // Turn on option(s)
///   acceptedFormats = acceptedFormats.turnOn(ImageFormat.gif & ImageFormat
///   .jpeg);
/// }
/// ```
///
/// This class is best used with the @option_set annotation/generator from this
/// package. It will auto-generate a subclass of [OptionSet] with
/// given options and all overrides. For more information, see package README.md
class OptionSet<T> {
  /// The underlying mask.
  final int rawValue;

  /// Designated constructor for all option sets.
  ///
  /// All subclasses must call this constructor.
  const OptionSet(this.rawValue);

  // START OVERRIDE //

  /// List of human-readable names of all the options this option set has
  /// available.
  ///
  /// This is purely for aesthetic purposes, used only in [toString]. Must use
  /// const constructor for list!
  ///
  /// See [OptionSet] docs for implementation example.
  final List<String> optionNames = const [];

  /// A de-facto constructor for each subclass. Creates a [T] object with the
  /// underlying integer mask [rawValue].
  ///
  /// Since there is no way for methods in [OptionSet] to know the constructors
  /// for the [T] type, this method delegates construction of [T] objects to
  /// the subclass itself.
  ///
  /// See [OptionSet] docs for implementation example.
  T initWithRawValue(int rawValue) {
    throw UnimplementedError('This method should be implemented by subclasses'
        ' of OptionSet. It should return a new instance of the subclass with '
        'the given raw value.');
  }

  // END OVERRIDE //

  // OPERATIONS

  /// Returns the logical AND (i.e. bitwise OR) of the options in both operands.
  ///
  /// Even though this method performs a bitwise OR of the underlying masks
  /// of both objects, the & operator is used for readability's sake.
  T operator &(OptionSet<T> optionSet) {
    return this.initWithRawValue(this.rawValue | optionSet.rawValue);
  }

  /// Toggles each option in the underlying mask.
  T operator ~() {
    return this.initWithRawValue(~this.rawValue);
  }

  /// Queries for the given [options].
  ///
  /// [options] can be either a singular option or a logical AND of options
  /// (created using the [&] method). If [options] is a combination of options,
  /// will return true only if ALL options in [options] are ON.
  bool has(OptionSet<T> options) {
    return (this.rawValue & options.rawValue) == options.rawValue;
  }

  /// Toggles [options] option(s).
  ///
  /// [options] can be either a singular option or a logical AND of options
  /// (created using the [&] method). If [options] is a combination of options,
  /// all options in [options] will be toggled.
  T toggle(OptionSet<T> options) {
    return this.initWithRawValue(this.rawValue ^ options.rawValue);
  }

  /// Turns on [options].
  ///
  /// [options] can be either a singular option or a logical AND of options
  /// (created using the [&] method). If [options] is a combination of options,
  /// all options in [options] will be turned on.
  T turnOn(OptionSet<T> options) {
    return this & options;
  }

  /// Turns off [options].
  ///
  /// [options] can be either a singular option or a logical AND of options
  /// (created using the [&] method). If [options] is a combination of options,
  /// all options in [options] will be turned off.
  T turnOff(OptionSet<T> options) {
    return this.initWithRawValue(this.rawValue & ~options.rawValue);
  }

  // EQUALITY

  // Since multiple OptionSet instances can have the same underlying
  // mask and yet be of different subtypes, the actual type must be checked
  // when testing for equality.
  @override
  bool operator ==(other) =>
      this.runtimeType == other.runtimeType && this.rawValue == other.rawValue;

  @override
  int get hashCode => this.runtimeType.hashCode + this.rawValue;

  // STRING

  /// Returns a human-readable representation of this option set.
  ///
  /// The returned representation includes the name of [T], a
  /// binary representation of the rawValue/mask, with the exact length of
  /// [optionNames].length, and a human-readable list of the options that are
  /// turned on using the names in [optionNames].
  ///
  /// Example:
  ///
  /// ```dart
  /// ImageFormat acceptedFormats = ImageFormat.png & ImageFormat.gif;
  /// print(acceptedFormats); // ImageFormat (1100): png, gif
  /// ```
  @override
  String toString() {
    String radixString = rawValue.toRadixString(2);
    int numberOfOptions = optionNames.length;
    int gap = numberOfOptions - radixString.length;

    radixString = radixString.padLeft(numberOfOptions, '0');

    if (gap < 0) {
      radixString = radixString.substring(-gap, radixString.length);
    }

    List<String> validOptionNames = [];
    for (int i = 0; i < optionNames.length; i++) {
      String option = optionNames[i];

      int rawOption = 1 << i;
      if ((rawValue & rawOption) != 0) {
        validOptionNames.add(option);
      }
    }

    return '${this.runtimeType} ($radixString): ${validOptionNames.join(','
        ' ')}';
  }
}
