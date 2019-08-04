import 'package:option_set/option_set.dart';

part 'example.g.dart';

class ImageFormat extends OptionSet<ImageFormat> {
  const ImageFormat._(rawValue) : super(rawValue);

  // OPTIONS //
  static final png = const ImageFormat._(1 << 0);
  static final jpeg = const ImageFormat._(1 << 1);
  static final svg = const ImageFormat._(1 << 2);
  static final gif = const ImageFormat._(1 << 3);

  static final master = png & jpeg;

  @override
  final List<String> optionNames = const ['png', 'jpeg', 'svg', 'gif'];

  @override
  ImageFormat initWithRawValue(int rawValue) {
    return ImageFormat._(rawValue);
  }
}

@Option_Set(
  merge: {'express': [_ShippingOptions.nextDay, _ShippingOptions.secondDay],},
)
enum _ShippingOptions {
  nextDay,
  secondDay,
  priority,
  standard
}