import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopit/data/network/endpoint.dart';
import 'package:shopit/data/network/response_utils.dart';
import 'package:shopit/model/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _expireAt;
  String? _userId;

  bool get sessionActive => token != null;

  String? get token {
    if (_expireAt != null &&
        _expireAt!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }

    return null;
  }

  Future<String?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return token;
  }

  Future<void> _authenticate(String email, String password, String path) async {
    final url = Uri.https(
      AUTH_URL,
      path,
      {'key': dotenv.env['WEB_API_KEY']},
    );

    final payload = jsonEncode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });

    print(url);
    print(payload);

    try {
      final response = await http.post(url, body: payload);
      tryResponseBody(
        response: response,
        failureAction: (error) {
          if (response.body.contains('EMAIL_EXISTS'))
            throw AuthException(
                'The email address is already in use by another account');

          if (response.body.contains('OPERATION_NOT_ALLOWED'))
            throw AuthException(
                'Password sign-in is disabled for this project');

          if (response.body.contains('TOO_MANY_ATTEMPTS_TRY_LATER'))
            throw AuthException(
                'We have blocked all requests from this device due to unusual activity. Try again later');

          if (response.body.contains('EMAIL_NOT_FOUND'))
            throw AuthException(
                'There is no user record corresponding to this identifier. The user may have been deleted');

          if (response.body.contains('INVALID_PASSWORD'))
            throw AuthException(
                'The password is invalid or the user does not have a password');

          if (response.body.contains('USER_DISABLED'))
            throw AuthException(
                'The user account has been disabled by an administrator');

          throw Exception('Authentication is failed. Try again later');
        },
        responseBodyAction: (data) async {
          if (data.containsKey('idToken')) {
            _token = data['idToken'];
            final prefs = await SharedPreferences.getInstance();
            final token = _token;
            if (token != null) await prefs.setString('auth_token', token);
            final tokenFromPrefs = prefs.getString('auth_token');
            print(tokenFromPrefs);
          }
          if (data.containsKey('localId')) {
            _userId = data['localId'];
          }
          if (data.containsKey('expiresIn')) {
            final int seconds = int.parse(data['expiresIn']);
            _expireAt = DateTime.now().add(Duration(seconds: seconds));
          }

          notifyListeners();
        },
      );
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, Endpoint.SignUp);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, Endpoint.SignIn);
  }
}
