import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Anything that lets someone *be* the user lives here:
/// iOS Keychain / Android Keystore — never shared_preferences.
class SecureStore {
  const SecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  /// null when there is no token — or when the OS can no longer decrypt it
  /// (Android: the lock screen was removed and the Keystore key is gone).
  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } on PlatformException {
      await clear();
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
