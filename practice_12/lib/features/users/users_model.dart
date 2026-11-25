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

  /// true when [items] is the saved list, not a fresh answer.
  bool fromCache = false;

  /// true while POST is in flight — the Save button is disabled.
  bool saving = false;

  /// Distinct, sorted cities of the loaded users — for the filter.
  List<String> get cities {
    final set = {
      for (final u in items)
        if (u.address.city.isNotEmpty) u.address.city,
    };
    return set.toList()..sort();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getAll();
      items = result.items;
      fromCache = result.fromCache;
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
