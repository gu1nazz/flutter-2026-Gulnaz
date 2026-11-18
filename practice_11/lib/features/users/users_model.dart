import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

/// Not a State and not a repository:
/// no BuildContext, no mounted, no http.
class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;

  /// true while POST is in flight — the Save button is disabled.
  bool saving = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Sends the draft, puts the returned user (with the server's id)
  /// at the top. Rethrows ApiException so the form can show a SnackBar.
  Future<void> create(User draft) async {
    if (saving) return; // a double tap sends one request
    saving = true;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      items = [created, ...items];
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
