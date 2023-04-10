import 'package:flutter/material.dart';
import 'package:my_shop/widgets/order_list_item.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Orders>(context, listen: false).fetchOrders(),
      builder: (ctx, data) {
        if (data.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Consumer<Orders>(
            builder: (context, orders, _) => ListView.builder(
              itemBuilder: (ctx, i) => OrderListItem(order: orders.orders[i]),
              itemCount: orders.orders.length,
            ),
          );
        }
      },
    );
  }
}
