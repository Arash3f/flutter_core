
# Secure Storage Usage/Examples

Keychain (iOS/macOS) and Keystore-backed EncryptedSharedPreferences (Android).
Use it for tokens and credentials only — every call crosses a platform channel,
so it is far slower than `SharedPrefs`.

Config instance:
```dart
const SecureStorage secureStorage = SecureStorage();
```

Every method takes named arguments.

Save data ?
```dart
await secureStorage.write(key: SecureStorage.token, value: 'ey…');
```

Read data ?
```dart
String? token = await secureStorage.read(key: SecureStorage.token);
// If it does not exist, returns null
```

Check a key ?
```dart
bool exists = await secureStorage.containsKey(key: SecureStorage.token);
```

Remove data ?
```dart
await secureStorage.delete(key: SecureStorage.token);
```

Clear all data ?
```dart
await secureStorage.clear();
```

## Keys

`SecureStorage.email`, `SecureStorage.password`, `SecureStorage.token`.

For the auth token prefer [`AppStorageHelper`](../helper_functions.dart), which
already wraps `getUserToken` / `setUserToken` / `clearUserToken`.

## Testing

Pass a `FlutterSecureStorage` instance to the constructor to inject a fake:

```dart
final storage = SecureStorage(myFakeSecureStorage);
```
