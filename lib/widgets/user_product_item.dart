import 'package:flutter/material.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String id;

  const UserProductItem(
      {super.key,
      required this.title,
      required this.imageUrl,
      required this.id});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        width: 99,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: id),
              icon: const Icon(Icons.edit),
              color: Theme.of(context).colorScheme.primary,
            ),
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text('Do you want to remove the item from the cart?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('No')),
                        TextButton(onPressed: () {
                          Provider.of<Products>(context, listen: false).deleteProduct(id);
                          Navigator.of(context).pop();
                        }, child: const Text('Yes')),
                      ],
                    ),

              ),
              icon: const Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
            )
          ],
        ),
      ),
    );
  }
}
