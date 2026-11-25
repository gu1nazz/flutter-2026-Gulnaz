import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

/// The last good list, kept in Documents (survives restarts and
/// "Clear cache"). Never Temporary: Temporary is temporary.
class UsersCache {
  static const _fileName = 'users.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> save(List<User> users) async {
    final file = await _file();
    await file.writeAsString(jsonEncode([for (final u in users) u.toJson()]));
  }

  /// null when nothing was saved yet (or the file is unreadable).
  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final data = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [
        for (final item in data) User.fromJson(item as Map<String, dynamic>),
      ];
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
