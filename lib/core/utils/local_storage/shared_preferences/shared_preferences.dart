import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for small, non-sensitive values.
///
/// [init] has to be awaited once, before `runApp`, otherwise every accessor
/// throws a [StateError] instead of failing later with a confusing
/// `LateInitializationError`.
class SharedPrefs {
  const SharedPrefs._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static bool get isInitialized => _prefs != null;

  static SharedPreferences get _storage {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPrefs.init() must be awaited before reading or writing values.',
      );
    }
    return prefs;
  }

  /// * Read data by [key]. Returns `null` when absent or of another type.
  static T? readData<T>(String key) {
    final value = _storage.get(key);
    return value is T ? value : null;
  }

  /// * Save data with [key] and [value]
  ///
  /// Supported types: `String`, `int`, `bool`, `double`, `List<String>`.
  static Future<bool> saveData<T>(String key, T value) {
    return switch (value) {
      final String v => _storage.setString(key, v),
      final int v => _storage.setInt(key, v),
      final bool v => _storage.setBool(key, v),
      final double v => _storage.setDouble(key, v),
      final List<String> v => _storage.setStringList(key, v),
      _ => throw ArgumentError.value(
          value,
          'value',
          'SharedPreferences cannot store ${value.runtimeType}',
        ),
    };
  }

  /// * Remove data by [key]
  static Future<bool> removeData(String key) => _storage.remove(key);

  /// * Clear all data in storage
  static Future<bool> clearAll() => _storage.clear();

  static bool containsKey(String key) => _storage.containsKey(key);

  /// ! My Keys
  static const String theme = 'theme';
  static const String lang = 'lang';
  static const String todos = 'todos';
}
