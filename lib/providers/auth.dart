import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:my_shop/env/env.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userID;

  Future<void> signup(String email, String pass) async {
    final url = Uri.https("identitytoolkit.googleapis.com",
        "/v1/accounts:signUp?key=${Env.apiKey}");
    final response = await post(url,
        body: json.encode(
            {'email': email, 'password': pass, 'returnSecureToken': true}));
  }
}