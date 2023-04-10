import 'package:flutter/material.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import 'user_products_screen.dart';
import 'cart_screen.dart';

enum FilterOptions { Favourites, All }

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isLoading = false;
  bool _showOnlyFavourites = false;
  int _selectedIndex = 0;
  late final List<Map<String, Widget>> _pages = [
    {
      'title': const Text('MyShop'),
      'page': ProductsGrid(showFavourites: _showOnlyFavourites),
    },
    {
      'title': const Text('Orders'),
      'page': const OrdersScreen(),
    },
    {
      'title': const Text('Personal Products',),
      'page': const UserProductsScreen(),
    }
  ];

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();
    Provider.of<Products>(context, listen: false).fetchProducts().then((_) => setState(() => _isLoading = false));
  }

  changeFavourites(FilterOptions val) {
    setState(() {
      val == FilterOptions.Favourites ? _showOnlyFavourites = true : _showOnlyFavourites = false;
    });

    _pages[0]['page'] = ProductsGrid(showFavourites: _showOnlyFavourites);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> overViewActions = [
      PopupMenuButton(
        onSelected: (val) => changeFavourites(val),
        icon: const Icon(Icons.more_vert,),
        itemBuilder: (_) => [
          const PopupMenuItem(
              value: FilterOptions.Favourites,
              child: Text('Only favourites')),
          const PopupMenuItem(
              value: FilterOptions.All, child: Text('Show All')),
        ],
      ),
      Consumer<Cart>(
        builder: (ctx, cart, btn) => BadgeOverlay(
          value: cart.itemCount.toString(),
          child: btn!,
        ),
        child: IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () =>
              Navigator.of(context).pushNamed(CartScreen.routeName),
        ),
      )
    ];
    final List<Widget> userProductsActions = [
      IconButton(onPressed: () => Navigator.pushNamed(context, EditProductScreen.routeName), icon: const Icon(Icons.add)),
    ];

    List<Widget> getActionsForScreen(int index) {
      switch (index) {
        case 0: return overViewActions;
        case 2: return userProductsActions;
      }
      return [];
    }

    return Scaffold(
      appBar: AppBar(
        title: _pages[_selectedIndex]['title'],
        actions: getActionsForScreen(_selectedIndex),
      ),
      body: _isLoading ?  const Center(child: CircularProgressIndicator(),) :_pages[_selectedIndex]['page'],
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        children: const [
          SizedBox(height: 20),
          NavigationDrawerDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: Text('Products'),
            selectedIcon: Icon(Icons.shopping_bag),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.text_snippet_outlined),
            label: Text('Orders'),
            selectedIcon: Icon(Icons.text_snippet),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.add_circle_outline),
            label: Text('User items'),
            selectedIcon: Icon(Icons.add_circle),
          ),
        ],
      ),
    );
  }
}
