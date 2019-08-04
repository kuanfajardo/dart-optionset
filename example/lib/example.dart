import 'package:option_set/option_set.dart';

class ImageFormat extends OptionSet<ImageFormat> {
  const ImageFormat._(rawValue) : super(rawValue);

  // OPTIONS //
  static final png = const ImageFormat._(1 << 0);
  static final jpeg = const ImageFormat._(1 << 1);
  static final svg = const ImageFormat._(1 << 2);
  static final gif = const ImageFormat._(1 << 3);

  static final rasters = png & jpeg;

  @override
  final List<String> optionNames = const ['png', 'jpeg', 'svg', 'gif'];

  @override
  ImageFormat initWithRawValue(int rawValue) {
    return ImageFormat._(rawValue);
  }
}

// Example usages
void main() {
  // Construction
  ImageFormat acceptedFormats = ImageFormat.png;
  print(acceptedFormats); // ImageFormat (0001): png

  // Combination
  acceptedFormats = acceptedFormats & ImageFormat.jpeg;
  print(acceptedFormats); // ImageFormat (0011): png, jpeg

  // Negation
  ImageFormat nonAcceptedFormats = ~acceptedFormats;
  print(nonAcceptedFormats); // ImageFormat (1100): svg, gif

  // Query (Single)
  bool isSvgAccepted = acceptedFormats.has(ImageFormat.svg);
  print(isSvgAccepted); // false

  bool isPngAccepted = acceptedFormats.has(ImageFormat.png);
  print(isPngAccepted); // true

  // Query (Compound)
  bool areBothSvgAndPngAccepted =
    acceptedFormats.has(ImageFormat.svg & ImageFormat.png);
  print(areBothSvgAndPngAccepted); // false

  bool areBothJpegAndPngAccepted =
    acceptedFormats.has(ImageFormat.jpeg & ImageFormat.png);
  print(areBothJpegAndPngAccepted); // true

  // Toggle (Single)
  acceptedFormats = acceptedFormats.toggle(ImageFormat.gif);
  print(acceptedFormats); // ImageFormat (1011): png, jpeg, gif

  // Toggle (Compound)
  acceptedFormats = acceptedFormats.toggle(ImageFormat.gif & ImageFormat.svg);
  print(acceptedFormats); // ImageFormat (0111): png, jpeg, svg

  // Turn off (Single)
  acceptedFormats = acceptedFormats.turnOff(ImageFormat.png);
  print(acceptedFormats); // ImageFormat (0110): jpeg, svg

  // Turn off (Compound)
  acceptedFormats = acceptedFormats.turnOff(ImageFormat.jpeg & ImageFormat.svg);
  print(acceptedFormats); // ImageFormat (0000):

  // ==
  OptionSet otherEmptyOptionSet = OptionSet(0);
  print(acceptedFormats.rawValue == otherEmptyOptionSet.rawValue); // true
  print(acceptedFormats == otherEmptyOptionSet); // false!

  ImageFormat otherEmptyImageFormat = ImageFormat._(0);
  print(acceptedFormats == otherEmptyImageFormat); // true
}