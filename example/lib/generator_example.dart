import 'package:option_set/option_set.dart';

part 'generator_example.g.dart';

// Simple
@option_set
enum Color {
  red,
  blue,
  green,
}

// Complex
@Option_Set(
  name: 'ShippingOptions',
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