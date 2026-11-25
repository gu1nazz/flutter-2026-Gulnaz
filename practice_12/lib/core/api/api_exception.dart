sealed class ApiException implements Exception {
  const ApiException();
}

// no response at all: SocketException or a timeout
class NoConnectionException extends ApiException {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}

// their server: 5xx
class ServerException extends ApiException {
  const ServerException(this.status);

  final int status;

  @override
  String toString() => 'ServerException($status)';
}

// my request: 4xx
class NotFoundException extends ApiException {
  const NotFoundException();

  @override
  String toString() => 'NotFoundException';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException';
}

// JSON we could not read: a bug report, not a Retry
class BadResponseException extends ApiException {
  const BadResponseException([this.detail]);

  final String? detail;

  @override
  String toString() => 'BadResponseException($detail)';
}
