import 'package:flutter/material.dart';
import 'package:my_shop/screens/app_drawer.dart';
import 'package:my_shop/widgets/order_list_item.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Orders orders = Provider.of<Orders>(context);
    return ListView.builder(
        itemBuilder: (ctx, i) => OrderListItem(order: orders.orders[i]),
        itemCount: orders.orders.length,
      );
  }
}
