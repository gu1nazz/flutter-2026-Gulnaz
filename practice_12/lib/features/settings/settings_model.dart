import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings live in shared_preferences. The initial values are read in
/// main() BEFORE runApp, so the first frame already has the right theme.
class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required this._dark,
    this._city,
    this._avatarPath,
  });

  final SharedPreferencesAsync _prefs;

  static const darkKey = 'darkMode';
  static const cityKey = 'cityFilter';
  static const avatarKey = 'avatarPath';

  bool _dark;
  String? _city;
  String? _avatarPath;

  bool get dark => _dark;
  String? get city => _city;
  String? get avatarPath => _avatarPath;

  /// The screen first, the disk second: the UI must not wait for the disk.
  Future<void> setDark(bool v) async {
    _dark = v;
    notifyListeners();
    await _prefs.setBool(darkKey, v);
  }

  /// null = "All cities" → the key is removed.
  Future<void> setCity(String? c) async {
    _city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove(cityKey);
    } else {
      await _prefs.setString(cityKey, c);
    }
  }

  Future<void> setAvatarPath(String? path) async {
    _avatarPath = path;
    notifyListeners();
    if (path == null) {
      await _prefs.remove(avatarKey);
    } else {
      await _prefs.setString(avatarKey, path);
    }
  }
}
