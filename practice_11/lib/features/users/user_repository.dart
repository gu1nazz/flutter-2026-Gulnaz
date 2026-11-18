import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

/// Screens ask for models and get models — or an ApiException.
/// Never a Response, never a status code, never a Map.
class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final http.Response r = await _api.send(
      (c) => c.get(_api.uri('/users'), headers: _api.headers),
    );
    final data = _api.decode(r);
    return _parse('users', () {
      final list = data as List<dynamic>;
      return [
        for (final item in list) User.fromJson(item as Map<String, dynamic>),
      ];
    });
  }

  Future<User> getById(int id) async {
    final http.Response r = await _api.send(
      (c) => c.get(_api.uri('/users/$id'), headers: _api.headers),
    );
    final data = _api.decode(r);
    return _parse(
      'users/$id',
      () => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<User> create(User draft) async {
    final body = draft.toJson()..remove('id'); // the server assigns the id
    final http.Response r = await _api.send(
      (c) => c.post(
        _api.uri('/users'),
        headers: _api.jsonHeaders,
        body: jsonEncode(body),
      ),
    );
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
