import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/app_drawer.dart';
import 'package:my_shop/screens/auth_screen.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Products()),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProvider(create: (ctx) => Orders()),
        ChangeNotifierProvider(create: (ctx) => Auth()),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
                colorScheme: lightDynamic ??
                    ColorScheme.fromSeed(
                        seedColor: Colors.deepPurple,
                        secondary: Colors.deepOrange),
                useMaterial3: true,
                fontFamily: 'Lato'),
            darkTheme: ThemeData(
                colorScheme: darkDynamic ??
                    ColorScheme.fromSeed(
                        brightness: Brightness.dark,
                        seedColor: Colors.deepPurple,
                        secondary: Colors.deepOrange),
                useMaterial3: true,
                fontFamily: 'Lato'),
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            home: auth.isAuth ? const AppDrawer() : const AuthScreen(),
            routes: {
              ProductDetailScreen.routeName: (ctx) =>
                  const ProductDetailScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            },
          );
        }),
      ),
    );
  }
}
