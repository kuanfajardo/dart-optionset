
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart';

class OptionSetGenerator extends GeneratorForAnnotation<Option_Set> {
  @override
  String generateForAnnotatedElement(Element element,
      ConstantReader annotation, BuildStep buildStep) {
    if (element is ClassElement) {
      // LOGGING
      element.fields.forEach((FieldElement field) {
        if (field.type.name == element.name) {
          log.info(field.name);
        }
      });

      // Read Annotation
      final String name = annotation.read('name').stringValue;
      final Map<DartObject, DartObject> merge = annotation.read('merge')
        .mapValue;
      final bool includeNone = annotation.read('none').boolValue;
      final bool includeAll = annotation.read('all').boolValue;

      log.info(name);
      log.info(merge);
      log.info(includeNone);
      log.info(includeAll);

      String className = name != ''
          ? name
          : element.name.startsWith('_')
            ? element.name.substring(1)
            : element.name + 'Options';

      Parameter rawValue = Parameter((b) => b..name = 'rawValue'..type = refer('int'));

      Constructor rawValueConstructor = Constructor((b) => b
          ..name = '_'
          ..requiredParameters.add(rawValue)
          ..initializers.add(Code('super(rawValue)'))
          ..constant = true
      );

      int i = 0;
      List<Field> options = element
          .fields
          .where((FieldElement field) => field.type.name == element.name).map<Field>((FieldElement field) =>
          Field((b) => b
        ..name = field.name
        ..static = true
        ..modifier = FieldModifier.final$
        ..assignment = Code('const $className._(1 << ${i++})')
      )).toList();

      Field noneOption;
      if (includeNone) {
        noneOption = Field((b) => b
            ..name = 'none'
            ..static = true
            ..modifier = FieldModifier.final$
            ..assignment = Code('const $className._(0)')
        );
      }

      List<Field> compoundOptions = [];
      if (merge.isNotEmpty) {
        merge.forEach((DartObject key, DartObject value) {
          String compoundOption = key.toStringValue();
          List<DartObject> _singleOptions = value.toListValue();

          List<String> singleOptions = [];
          _singleOptions.forEach((DartObject option) {
            singleOptions.add(
                option.toString().substring(
                    element.nameLength + 2,
                    option.toString().indexOf('=') - 1
                )
            );
          });

          log.info(singleOptions);

          Field compound = Field((b) => b
              ..name = compoundOption
              ..static = true
              ..modifier = FieldModifier.final$
              ..assignment = Code(singleOptions.join(' & '))
          );

          compoundOptions.add(compound);
        });
      }

      List<String> _optionNames = options.map<String>((Field field) => field
          .name).toList();

      Field allOption;
      if (includeAll) {
        String _allOptionsAssignment = _optionNames.join(' & ');
        allOption = Field((b) => b
          ..name = 'all'
          ..static = true
          ..modifier = FieldModifier.final$
          ..assignment = Code(_allOptionsAssignment)
        );
      }

      String _optionNamesAssignment = '[${_optionNames.map((e) => '\'$e\'').join(', ')}]';

      Field optionNames = Field((b) => b
          ..name = 'optionNames'
          ..type = refer('List<String>')
          ..modifier = FieldModifier.final$
          ..annotations.add(refer('override'))
          ..assignment = Code('const $_optionNamesAssignment')
      );

      Method initWithRawValue = Method((b) => b
          ..name = 'initWithRawValue'
          ..annotations.add(refer('override'))
          ..returns = refer(className)
          ..requiredParameters.add(rawValue)
          ..body = Code('return $className._(rawValue);')
      );

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
          ..fields.add(optionNames)
          ..methods.add(initWithRawValue)
          ..extend = refer('OptionSet<$className>')
      );

      return specToString(optionSet);
    }

    return null;
  }
}

String specToString(Spec spec) {
  // Generate code and return
  final DartEmitter emitter = DartEmitter();
  final String generatedCode = '${spec.accept(emitter)}';
  return DartFormatter().format(generatedCode);
}