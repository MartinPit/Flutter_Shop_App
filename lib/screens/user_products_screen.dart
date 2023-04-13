import 'package:flutter/material.dart';
import 'package:my_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> refreshData(BuildContext context) async {
      await Provider.of<Products>(context, listen: false).fetchProducts(true);
    }

    return FutureBuilder(
      future: refreshData(context),
      builder: (context, snapshot) =>
      snapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: () => refreshData(context),
        child: Consumer<Products>(
          builder: (context, products, _) => Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              itemBuilder: (ctx, i) =>
                  Column(
                    children: [
                      UserProductItem(
                        title: products.items[i].title,
                        imageUrl: products.items[i].imageUrl,
                        id: products.items[i].id,
                      ),
                      const Divider(),
                    ],
                  ),
              itemCount: products.items.length,
            ),
          ),
        ),
      ),
    );
  }
}
