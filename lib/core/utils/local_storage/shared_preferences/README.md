
# Shared Preferences Usage/Examples

For small, non-sensitive values: theme, language, feature flags, ids.
Tokens and passwords belong in [Secure Storage](../secure_storage/README.md).

`SharedPrefs` is a static API — there is nothing to construct. `init()` must be
awaited once in `main()` before `runApp`, otherwise every accessor throws a
`StateError`:

```dart
await SharedPrefs.init();
```

Save data ?
```dart
await SharedPrefs.saveData(SharedPrefs.lang, 'en');
```
Supported types: `String`, `int`, `bool`, `double`, `List<String>`.
Anything else throws an `ArgumentError`.

Read data ?
```dart
String? lang = SharedPrefs.readData<String>(SharedPrefs.lang);
// Returns null when the key is absent or holds another type
```

Remove data ?
```dart
await SharedPrefs.removeData(SharedPrefs.lang);
```

Check a key ?
```dart
bool exists = SharedPrefs.containsKey(SharedPrefs.lang);
```

Clear all data ?
```dart
await SharedPrefs.clearAll();
```

## Keys

Every key is a constant on the class, so a rename never leaves a stale string
literal in a widget: `SharedPrefs.theme`, `SharedPrefs.lang`,
`SharedPrefs.todos`.

Prefer the typed wrappers in [`AppStorageHelper`](../helper_functions.dart)
over reading these keys directly.
