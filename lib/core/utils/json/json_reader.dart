/// Lenient reads from a decoded JSON map.
///
/// Each getter takes several candidate keys and returns the first present
/// one, which absorbs `snake_case` / `camelCase` differences between
/// endpoints without a pile of `??` chains in every model.
class JsonReader {
  const JsonReader(this._json);

  final Map<String, dynamic> _json;

  Object? _first(List<String> keys) {
    for (final key in keys) {
      final value = _json[key];
      if (value != null) return value;
    }
    return null;
  }

  String? string(String key, [String? alt1, String? alt2]) =>
      _first([key, ?alt1, ?alt2])?.toString();

  bool boolean(String key, [String? alt]) => _first([key, ?alt]) == true;

  DateTime? date(String key, [String? alt]) {
    final value = _first([key, ?alt]);
    return value is String ? DateTime.tryParse(value) : null;
  }

  List<String> strings(String key) {
    final value = _json[key];
    return value is List ? value.map((item) => '$item').toList() : const [];
  }
}
