import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:my_shop/env/env.dart';
import 'package:my_shop/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryDate == null || !_expiryDate!.isAfter(DateTime.now())) {
      return null;
    }

    return _token;
  }

  Future<void> _authenticate(String email, String pass, String endpoint) async {
    final url = Uri.https(
        'identitytoolkit.googleapis.com', endpoint, {'key': Env.apiKey});

    final response = await post(url,
        body: json.encode(
            {'email': email, 'password': pass, 'returnSecureToken': true}));

    final data = json.decode(response.body);

    if (data['error'] != null) {
      throw HttpException(data['error']['message']);
    }

    _token = data['idToken'];
    _userId = data['localId'];
    _expiryDate =
        DateTime.now().add(Duration(seconds: int.parse(data['expiresIn'])));
    _autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _expiryDate!.toIso8601String()
    });
    prefs.setString('userData', userData);
  }

  Future<void> signup(String email, String pass) async {
    return _authenticate(email, pass, '/v1/accounts:signUp');
  }

  Future<void> login(String email, String pass) async {
    return _authenticate(email, pass, '/v1/accounts:signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final Map<String, dynamic> userData = json.decode(prefs.getString('userData')!);
    final expiryDate = DateTime.parse(userData['expiryDate']!);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _expiryDate = expiryDate;
    _token = userData['token']!;
    _userId = userData['userId']!;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    _authTimer == null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: timeToExpiry),
      logout,
    );
  }
}
