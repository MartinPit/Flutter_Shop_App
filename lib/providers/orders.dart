import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.datetime});
}

class Orders with ChangeNotifier {
  final url = Uri.https(
      'flutter-shop-app-1f679-default-rtdb.europe-west1.firebasedatabase.app',
      '/orders.json');
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'datetime': timestamp.toIso8601String(),
          'products': products
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price
                  })
              .toList(),
        }));

    if (response.statusCode >= 400) {
      throw HttpException('Failed to create order');
    }

    _orders.insert(
        0,
        OrderItem(
            id: DateTime.now().toString(),
            amount: total,
            products: products,
            datetime: timestamp));
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _orders.clear();
    final response = await http.get(url);
    final data = json.decode(response.body);
    if (data == null) {
      return;
    }
    data.forEach((id, order) {
      _orders.insert(0, OrderItem(
          id: id,
          amount: order['amount'],
          products: (order['products'] as List<dynamic>)
              .map((e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price']))
              .toList(),
          datetime: DateTime.parse(order['datetime'])));
    });
    notifyListeners();
  }
}
