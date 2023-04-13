import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

import 'product.dart';

class Products with ChangeNotifier {
  final List<Product> _items;
  final String token;
  final String userId;

  Products(this._items, this.userId, {required this.token});

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favourites {
    return _items.where((item) => item.isFavourite).toList();
  }

  Product getProduct({required id}) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    _items.clear();
    Map<String, String> parameters = {};
    if (filterByUser) {
      parameters = {
        'auth': token,
        'orderBy': json.encode("userId"),
        'equalTo': '"$userId"'
      };
    } else {
      parameters = {
        'auth': token,
      };
    }


    final response = await http.get(Uri.https(
        'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
        '/products.json', parameters));
    final decodedData = json.decode(response.body) as Map<String, dynamic>;

    final favourites = await http.get(Uri.https(
        'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
        '/userFavourites/$userId.json',
        {'auth': token}));

    final decodedFavourites = json.decode(favourites.body);

    decodedData.forEach((id, data) => _items.add(Product(
        id: id,
        title: data['title'],
        description: data['description'],
        price: data['price'],
        imageUrl: data['imageUrl'],
        isFavourite: decodedFavourites == null
            ? false
            : decodedFavourites[id] ?? false)));

    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.https(
            'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
            '/products.json',
            {'auth': token}),
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'userId': userId,
          },
        ),
      );

      _items.add(Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl));
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index < 0) {
      return;
    }
    await http.patch(
        Uri.https(
            'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
            '/products/$id.json',
            {'auth': token}),
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }));

    _items[index] = Product(
        id: newProduct.id,
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final int prodIndex = _items.indexWhere((element) => element.id == id);
    Product? product = _items[prodIndex];
    _items.removeAt(prodIndex);
    notifyListeners();

    final Uri url = Uri.https(
        'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$id.json',
        {'auth': token});
    final response = await http.delete(url);

    if (response.statusCode > 400) {
      _items.insert(prodIndex, product);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }

    product = null;
  }
}
