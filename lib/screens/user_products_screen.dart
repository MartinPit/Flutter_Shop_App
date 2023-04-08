import 'package:flutter/material.dart';
import 'package:my_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Products productsData = Provider.of<Products>(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemBuilder: (ctx, i) => Column(
          children: [
            UserProductItem(
              title: productsData.items[i].title,
              imageUrl: productsData.items[i].imageUrl,
              id: productsData.items[i].id,
            ),
            const Divider(),
          ],
        ),
        itemCount: productsData.items.length,
      ),
    );
  }
}
