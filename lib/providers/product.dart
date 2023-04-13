import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleFavorite(String token) async {
    final Uri url = Uri.https(
        'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$id.json', {'auth': token});
    isFavourite = !isFavourite;
    notifyListeners();
    final response = await http.patch(url, body: json.encode({'isFavourite': !isFavourite}));

    if (response.statusCode >= 400) {
      isFavourite = !isFavourite;
      notifyListeners();
      throw HttpException('Failed to changed the favourite status');
    }
  }
}
