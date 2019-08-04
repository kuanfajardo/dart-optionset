/// Annotation for auto-generation of an OptionSet.
///
/// May only be used on `enum` types. See [https://github.com/kuanfajardo/dart-optionset/blob/master/example/lib/generator_example.dart]
/// for example usage.
class Option_Set {
  /// Name to use for generated option set.
  ///
  /// If not set, will look at annotated enum name. If the enum name starts
  /// with '_', the generated option set name will be the enum name minus the
  /// leading '_'. Otherwise, the option set name will be the enum name with
  /// 'Options' appended to it.
  final String name;

  /// Map of compound option names to a list of the enum values to use to
  /// construct the compound option.
  final Map<String, List<Object>> compound;

  /// If true, will generate a `none` option. Defaults to `false`.
  final bool includeNone;

  /// If true, will generate an `all` option. Defaults to `false`.
  final bool includeAll;

  const Option_Set({
    this.name = '',
    this.compound = const {},
    this.includeNone = false,
    this.includeAll = false,
  });
}

/// Convenience annotation for simple uses.
const Object option_set = Option_Set();