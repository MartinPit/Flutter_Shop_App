import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/cart.dart';
import '../providers/orders.dart';

class OrderListItem extends StatefulWidget {
  final OrderItem order;

  const OrderListItem({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final List<CartItem> products = widget.order.products;
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.order.amount.toStringAsFixed(2)}'),
              subtitle: Text(
                  DateFormat('dd.MM.yyyy hh:mm').format(widget.order.datetime)),
              trailing: IconButton(
                icon: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, maxRadius: 15,child: Icon(_expanded ? Icons.expand_less : Icons.expand_more), ),
                onPressed: () => setState(() {
                  _expanded = !_expanded;
                }),
              ),
            ),
            if (_expanded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: min(products.length * 32, 150),
                child: ListView.builder(
                  itemBuilder: (ctx, i) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        products[i].title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${products[i].quantity}x \$${products[i].price.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  itemCount: widget.order.products.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
