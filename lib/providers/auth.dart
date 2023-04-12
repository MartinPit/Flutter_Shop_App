import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:my_shop/env/env.dart';
import 'package:my_shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userID;

  Future<void> _authenticate(String email, String pass, String endpoint) async {
    final url = Uri.https('identitytoolkit.googleapis.com',
       endpoint, {'key': Env.apiKey});

    final response = await post(url,
        body: json.encode(
            {'email': email, 'password': pass, 'returnSecureToken': true}));

    final data = json.decode(response.body);
    print(data);
    if (data['error'] != null) {
      throw HttpException(data['error']['message']);
    }
  }

  Future<void> signup(String email, String pass) async {
    return _authenticate(email, pass, '/v1/accounts:signUp');
  }

  Future<void> login(String email, String pass) async {
    return _authenticate(email, pass, '/v1/accounts:signInWithPassword');
  }
}
