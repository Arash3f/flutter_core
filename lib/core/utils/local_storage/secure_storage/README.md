
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
await secureStorage.write(key: SecureStorage.accessToken, value: 'ey…');
```

Read data ?
```dart
String? token = await secureStorage.read(key: SecureStorage.accessToken);
// If it does not exist, returns null
```

Check a key ?
```dart
bool exists = await secureStorage.containsKey(key: SecureStorage.accessToken);
```

Remove data ?
```dart
await secureStorage.delete(key: SecureStorage.accessToken);
```

Clear all data ?
```dart
await secureStorage.clear();
```

## Keys

`SecureStorage.accessToken`, `SecureStorage.refreshToken`,
`SecureStorage.tokenType`.

Never store the user's password: the refresh token is what keeps a session
alive. For tokens prefer [`AppStorageHelper`](../helper_functions.dart), which
wraps `getAccessToken` / `getRefreshToken` / `setTokens` / `clearTokens`.

## Testing

Pass a `FlutterSecureStorage` instance to the constructor to inject a fake:

```dart
final storage = SecureStorage(myFakeSecureStorage);
```
