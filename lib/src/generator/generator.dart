import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart';

class OptionSetGenerator extends GeneratorForAnnotation<Option_Set> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // Enum is read as ClassElement
    if (element is ClassElement) {
      // Extract user info from annotation.
      final String name = annotation.read('name').stringValue;
      final Map<DartObject, DartObject> compound =
          annotation.read('compound').mapValue;
      final bool includeNone = annotation.read('includeNone').boolValue;
      final bool includeAll = annotation.read('includeAll').boolValue;

      String className = name != ''
          ? name
          : element.name.startsWith('_')
              ? element.name.substring(1)
              : element.name + 'Options';

      // DEFINE OPTIONS
      int i = 0;
      List<Field> options = element.fields
          .where((FieldElement field) => field.type.name == element.name)
          .map<Field>((FieldElement field) =>
              optionField(field.name, 'const $className._(1 << ${i++})'))
          .toList();

      List<String> optionNames =
          options.map<String>((Field field) => field.name).toList();

      // .none
      Field noneOption;
      if (includeNone) {
        noneOption = optionField('none', 'const $className._(0)');
      }

      // Compound Options
      List<Field> compoundOptions = [];
      if (compound.isNotEmpty) {
        compound.forEach((DartObject key, DartObject value) {
          String compoundOptionName = key.toStringValue();
          List<DartObject> singleOptions = value.toListValue();

          // Extract names of single options from list of enum values.
          List<String> singleOptionNames =
              singleOptions.map((DartObject option) {
            // _$className ($optionName = int($i))
            String optionAsString = option.toString();

            int optionNameStart = element.nameLength + 2; // +2 for ' ('
            int optionNameEnd = optionAsString.indexOf(' =');

            return optionAsString.substring(optionNameStart, optionNameEnd);
          }).toList();

          Field compoundOption = optionField(
              compoundOptionName,
              singleOptionNames.join(' &'
                  ' '));
          compoundOptions.add(compoundOption);
        });
      }

      // .all
      Field allOption;
      if (includeAll) {
        String _allOptionsAssignment = optionNames.join(' & ');
        allOption = optionField('all', _allOptionsAssignment);
      }

      // Used in both constructor and initWithRawValue
      Parameter rawValue = Parameter((b) => b
        ..name = 'rawValue'
        ..type = refer('int'));

      // CONSTRUCTOR
      Constructor rawValueConstructor = Constructor((b) => b
        ..name = '_'
        ..requiredParameters.add(rawValue)
        ..initializers.add(Code('super(rawValue)'))
        ..constant = true);

      // OVERRIDES

      // optionNames
      String _optionNamesAssignment =
          '[${optionNames.map((e) => '\'$e\'').join(', ')}]';

      Field optionNamesField = Field((b) => b
        ..name = 'optionNames'
        ..type = refer('List<String>')
        ..modifier = FieldModifier.final$
        ..annotations.add(refer('override'))
        ..assignment = Code('const $_optionNamesAssignment'));

      // initWithRawValue
      Method initWithRawValue = Method((b) => b
        ..name = 'initWithRawValue'
        ..annotations.add(refer('override'))
        ..returns = refer(className)
        ..requiredParameters.add(rawValue)
        ..body = Code('return $className._(rawValue);'));

      // Combine all options in the following order:
      // .none (if present), single options, compound options, .all (if present)
      if (noneOption != null) {
        options.insert(0, noneOption);
      }

      if (compoundOptions.isNotEmpty) {
        options += compoundOptions;
      }

      if (allOption != null) {
        options.add(allOption);
      }

      Class optionSet = Class((b) => b
        ..name = className
        ..constructors.add(rawValueConstructor)
        ..fields.addAll(options)
        ..fields.add(optionNamesField)
        ..methods.add(initWithRawValue)
        ..extend = refer('OptionSet<$className>'));

      return specToString(optionSet);
    }

    return null;
  }
}

// Convenience method for creating a static final field (i.e. an option).
Field optionField(String name, String assignment) {
  return Field((b) => b
    ..name = name
    ..static = true
    ..modifier = FieldModifier.final$
    ..assignment = Code(assignment));
}

String specToString(Spec spec) {
  // Generate code and return
  final DartEmitter emitter = DartEmitter();
  final String generatedCode = '${spec.accept(emitter)}';
  return DartFormatter().format(generatedCode);
}
