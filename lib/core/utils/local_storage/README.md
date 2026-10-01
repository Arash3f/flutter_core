
# Local Storage

Two storages ship with the project, split by sensitivity:

| Storage | Package | Use it for |
|---|---|---|
| [`SharedPrefs`](./shared_preferences/README.md) | [shared_preferences](https://pub.dev/packages/shared_preferences) | theme, language, small flags, cached lists |
| [`SecureStorage`](./secure_storage/README.md) | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | tokens, credentials |

`SharedPrefs.init()` has to be awaited in `main()` before `runApp`.

## Helper Function

[`AppStorageHelper`](./helper_functions.dart) is the typed front door. Widgets
should go through it instead of touching raw keys:

```dart
LanguageList language = AppStorageHelper.getActiveLanguage();
await AppStorageHelper.setActiveLanguage(LanguageList.persian);

ThemeMode mode = AppStorageHelper.getActiveTheme();
await AppStorageHelper.setActiveTheme(ThemeMode.dark);

String? access = await AppStorageHelper.getAccessToken();
String? refresh = await AppStorageHelper.getRefreshToken();
await AppStorageHelper.setTokens(accessToken: 'ey…', refreshToken: 'ey…');
await AppStorageHelper.clearTokens();
```

Tokens are written by the auth feature
([`AuthLocalDataSource`](../../../features/auth/data/datasources/auth_local_data_source.dart))
and read by the network layer on every request. Other code should not need
them.

In the widget tree, read these through
[`appSettingsProvider`](../../providers/app_settings_provider.dart) rather than
calling the helper directly, so the UI rebuilds when a value changes.

## Not included

- [Get Storage](https://pub.dev/packages/get_storage) — GetX ecosystem;
  `SharedPrefs` covers the same ground here.
- [Flutter Cache Manager](https://pub.dev/packages/flutter_cache_manager) — add
  it when you need image/file cache management.
- [Hive](https://pub.dev/packages/hive) / [sqflite](https://pub.dev/packages/sqflite)
  — for larger datasets or queries. Swapping a data source implementation is
  enough; see [`features/README.md`](../../../features/README.md).
