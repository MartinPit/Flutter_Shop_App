import 'package:flutter/material.dart';
import 'package:my_shop/widgets/product_item.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavourites;

  const ProductsGrid({super.key, required this.showFavourites});

  @override
  Widget build(BuildContext context) {
    Products products = Provider.of<Products>(context);
    List<Product> productList = showFavourites ? products.favourites : products.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (ctx, idx) => ChangeNotifierProvider.value(
        value: productList[idx],
        child: const ProductItem(),
      ),
      itemCount: productList.length,
    );
  }
}