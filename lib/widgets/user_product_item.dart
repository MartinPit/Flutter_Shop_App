import 'package:flutter/material.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String id;

  const UserProductItem({super.key,
    required this.title,
    required this.imageUrl,
    required this.id});

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
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
              onPressed: () =>
                  Navigator.of(context)
                      .pushNamed(EditProductScreen.routeName, arguments: id),
              icon: const Icon(Icons.edit),
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
            ),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(id);
                } catch (error) {
                  messenger.showSnackBar(const SnackBar(content: Text('Deleting failed'), behavior: SnackBarBehavior.floating,));
                }
              },
              icon: const Icon(Icons.delete),
              color: Theme
                  .of(context)
                  .colorScheme
                  .error,
            )
          ],
        ),
      ),
    );
  }
}
