import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

// main.dart creates the Client through this export, so that
// `grep -rn "package:http" lib/` lists only api_client.dart
// and user_repository.dart.
export 'package:http/http.dart' show Client;

/// The single place that talks to the network:
/// timeout, headers (with the token), status codes, JSON decoding, logging.
class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  final http.Client _client;
  final SecureStore _store;
  final String host;

  static const _timeout = Duration(seconds: 10);

  /// All headers live here. The token is added by ApiClient itself:
  /// the repository never sees it, the screen never sees the header.
  Future<Map<String, String>> _headers() async => {
    'Accept': 'application/json',
    if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
  };

  /// Builds an address. Never string concatenation.
  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.https(host, path, query);

  Future<http.Response> get(Uri uri) =>
      _request((headers) => _client.get(uri, headers: headers));

  Future<http.Response> post(Uri uri, Object? body) => _request(
    (headers) => _client.post(
      uri,
      headers: {...headers, 'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(body),
    ),
  );

  /// Decodes the body; a broken body becomes [BadResponseException].
  dynamic decode(http.Response r) => _decode(r);

  Future<http.Response> _request(
    Future<http.Response> Function(Map<String, String> headers) call,
  ) async {
    final headers = await _headers();
    final response = await _send(() => call(headers));
    _check(response);
    return response;
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(_timeout);
      if (kDebugMode) {
        // method, path and status only — never the headers (the token!)
        log(
          '${response.request?.method} ${response.request?.url} '
          '→ ${response.statusCode}',
          name: 'api',
        );
      }
      return response;
    } on SocketException catch (e) {
      _logError(e);
      throw const NoConnectionException();
    } on TimeoutException catch (e) {
      _logError(e);
      throw const NoConnectionException();
    } on http.ClientException catch (e) {
      // On web there is no SocketException: network failures arrive here.
      _logError(e);
      throw const NoConnectionException();
    }
  }

  void _logError(Object e) {
    if (kDebugMode) log('network error: $e', name: 'api');
  }

  void _check(http.Response r) {
    final status = r.statusCode;
    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException catch (e) {
      throw BadResponseException('not JSON: ${e.message}');
    }
  }
}
