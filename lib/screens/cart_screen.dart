import 'package:flutter/material.dart';
import 'package:my_shop/widgets/cart_list_item.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Cart cart = Provider.of<Cart>(context);
    final messenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart!'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color:
                          Theme
                              .of(context)
                              .colorScheme
                              .onPrimaryContainer),
                    ),
                    backgroundColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .primaryContainer,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  OutlinedButton(
                    onPressed: cart.itemCount > 0 ? () async {
                      try {
                        await Provider.of<Orders>(context, listen: false)
                            .addOrder(cart.items.values.toList(),
                            cart.totalAmount);
                        cart.clear();
                      } catch (error) {
                        messenger.showSnackBar(SnackBar(content: Text(error.toString()), behavior: SnackBarBehavior.floating,));
                      }
                    } : null,
                    child: const Text('Order Now'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) =>
                  CartListItem(
                    id: cart.items.values.toList()[i].id,
                    productId: cart.items.keys.toList()[i],
                    title: cart.items.values.toList()[i].title,
                    quantity: cart.items.values.toList()[i].quantity,
                    price: cart.items.values.toList()[i].price,
                  ),
              itemCount: cart.items.length,
            ),
          ),
        ],
      ),
    );
  }
}
