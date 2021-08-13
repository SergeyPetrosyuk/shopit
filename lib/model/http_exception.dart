import 'package:http/http.dart';

class HttpExceptions implements Exception {
  final Response response;

  HttpExceptions(this.response);

  int get statusCode => response.statusCode;

  String get message {
    if (statusCode == 404) {
      return 'Not found';
    }

    if (statusCode == 405) {
      return 'Bad request. ${response.body}';
    }

    if (statusCode >= 500) {
      return 'Server error';
    }

    if (statusCode == 401) {
      return 'You are not authorized';
    }

    return 'Something went wrong';
  }

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}