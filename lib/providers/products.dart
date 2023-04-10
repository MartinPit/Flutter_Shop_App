import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

class Products with ChangeNotifier {
  final url = Uri.https(
      'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
      '/products.json');
  final List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favourites {
    return _items.where((item) => item.isFavourite).toList();
  }

  Product getProduct({required id}) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchProducts() async {
    _items.clear();
    final response = await http.get(url);
    final Map<String, dynamic> decodedData = json.decode(response.body);
    decodedData.forEach((id, data) => _items.add(Product(
        id: id,
        title: data['title'],
        description: data['description'],
        price: data['price'],
        imageUrl: data['imageUrl'],
        isFavourite: data['isFavourite'])));

    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavourite': product.isFavourite,
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
            '/products/$id.json'),
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

  void deleteProduct(String id) {
    final int prodIndex = _items.indexWhere((element) => element.id == id);
    Product? product = _items[prodIndex];
    _items.removeAt(prodIndex);

    http
        .delete(
          Uri.https(
              'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
              '/products/$id.on'),
        )
        .then((response) {
          if (response.statusCode > 400) {
            
          }
          return product = null;
        })
        .catchError((_) {
      _items.insert(prodIndex, product!);
      return;
    });
    notifyListeners();
  }
}
