import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();

  @override
  String toString() => 'InvalidCredentialsException';
}

/// A fake login with a real secure store.
class AuthModel extends ChangeNotifier {
  /// [token] is read from the secure store in main() before runApp.
  AuthModel(this._store, {this._token});

  final SecureStore _store;
  String? _token;
  bool busy = false;

  bool get signedIn => _token != null;

  /// Only for the debug "Copy token" button. Never print it.
  String? get token => _token;

  /// Fake: any password of 8+ characters returns `tok_<hash>` after 1 s.
  Future<void> login(String email, String password) async {
    busy = true;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (password.length < 8) throw const InvalidCredentialsException();
      final t = 'tok_${email.hashCode}';
      await _store.saveToken(t);
      _token = t;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}
