import 'package:build/build.dart';
import 'package:option_set/src/generator/generator.dart';
import 'package:source_gen/source_gen.dart';

Builder optionSetBuilder(BuilderOptions options) => SharedPartBuilder(
      [OptionSetGenerator()], 'option_set');
