import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

// main.dart creates the Client through this export, so that
// `grep -rn "package:http" lib/` lists only api_client.dart
// and user_repository.dart.
export 'package:http/http.dart' show Client;

/// The single place that talks to the network:
/// timeout, status codes, JSON decoding, headers, logging.
class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  static const _timeout = Duration(seconds: 10);

  /// All headers live here.
  Map<String, String> get headers => const {'Accept': 'application/json'};

  /// Headers for requests that carry a JSON body.
  Map<String, String> get jsonHeaders => {
    ...headers,
    'Content-Type': 'application/json; charset=utf-8',
  };

  /// Builds an address. Never string concatenation.
  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.https(host, path, query);

  /// Sends a request: timeout + status check.
  /// Returns a successful response or throws an [ApiException].
  Future<http.Response> send(
    Future<http.Response> Function(http.Client client) call,
  ) async {
    final response = await _send(() => call(_client));
    _check(response);
    return response;
  }

  /// Decodes the body; a broken body becomes [BadResponseException].
  dynamic decode(http.Response r) => _decode(r);

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(_timeout);
      if (kDebugMode) {
        log(
          '${response.request?.method} ${response.request?.url} '
          '→ ${response.statusCode}',
          name: 'api',
        );
      }
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      // package:http may wrap a socket error into ClientException.
      throw const NoConnectionException();
    }
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
