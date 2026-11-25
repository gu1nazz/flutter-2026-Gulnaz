import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

/// The result says where the list came from.
typedef UsersResult = ({List<User> items, bool fromCache});

/// Screens ask for models and get models — or an ApiException.
/// Never a Response, never a status code, never a Map, never the token.
class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  /// Online: fresh list, saved to disk. Offline: the last saved list.
  /// Offline and nothing saved: the NoConnectionException goes up.
  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetchAll();
      await _saveQuietly(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<User> getById(int id) async {
    final http.Response r = await _api.get(_api.uri('/users/$id'));
    final data = _api.decode(r);
    return _parse(
      'users/$id',
      () => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<User> create(User draft) async {
    final body = draft.toJson()..remove('id'); // the server assigns the id
    final http.Response r = await _api.post(_api.uri('/users'), body);
    if (r.statusCode != 201) {
      throw BadResponseException(
        'POST users: expected 201, got ${r.statusCode}',
      );
    }
    final data = _api.decode(r);
    return _parse(
      'POST users',
      () => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<User>> _fetchAll() async {
    final http.Response r = await _api.get(_api.uri('/users'));
    final data = _api.decode(r);
    return _parse('users', () {
      final list = data as List<dynamic>;
      return [
        for (final item in list) User.fromJson(item as Map<String, dynamic>),
      ];
    });
  }

  /// A full disk must not turn a good answer into an error.
  Future<void> _saveQuietly(List<User> users) async {
    try {
      await _cache.save(users);
    } on FileSystemException catch (e) {
      debugPrint('cache save failed: $e');
    }
  }

  /// A cast that throws inside fromJson becomes BadResponseException.
  T _parse<T>(String where, T Function() build) {
    try {
      return build();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
