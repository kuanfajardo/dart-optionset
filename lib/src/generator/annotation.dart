class Option_Set {
  final String name;
  final Map<String, List<Object>> merge;
  final bool none;
  final bool all;

  const Option_Set({
    this.name = '',
    this.merge = const {},
    this.none = true,
    this.all = true
  });
}

const Object option_set = Option_Set();