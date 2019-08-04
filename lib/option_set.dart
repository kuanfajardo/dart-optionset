/// This library brings option sets (i.e. bitmasks) to Dart.
///
/// There are two classes provided:
///
/// [OptionSet] is the main class of this package. It serves as a
/// superclass that provides the option set functionality to its subclasses.
///
/// [Option_Set] is the annotation for automatic generation of
/// [OptionSet] subclasses with the use of `build_runner'.
library option_set;

export 'src/option_set.dart';

export 'src/generator/annotation.dart';