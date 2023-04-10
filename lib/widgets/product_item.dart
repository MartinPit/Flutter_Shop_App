import 'package:flutter/material.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = Provider.of<Product>(context);
    final Cart cart = Provider.of<Cart>(context);
    final messenger = ScaffoldMessenger.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: Icon(product.isFavourite
                  ? Icons.favorite
                  : Icons.favorite_border_outlined),
              onPressed: () async {
                try {
                  await product.toggleFavorite();
                } catch (error) {
                  messenger.showSnackBar(SnackBar(content: Text(error.toString()), behavior: SnackBarBehavior.floating,));
                }
              },
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          backgroundColor: Theme.of(context)
              .colorScheme
              .secondaryContainer
              .withOpacity(0.90),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              SnackBar snackBar = SnackBar(
                content: const Text('Added item to cart!'),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => cart.removeSingleItem(product.id),
                    textColor: Theme.of(context).colorScheme.inversePrimary),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
