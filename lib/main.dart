import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/cart_provider.dart';
import 'package:shopit/data/provider/orders_providers.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/presentation/cart/cart_route.dart';
import 'package:shopit/presentation/navigation/routes.dart';
import 'package:shopit/presentation/orders_overview/orders_route.dart';
import 'package:shopit/presentation/product_detail/product_detail_route.dart';
import 'package:shopit/presentation/products_overview/products_overview_route.dart';
import 'package:shopit/presentation/tabs/tabs_route.dart';
import 'package:shopit/presentation/user_products/add_edit_user_product_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'ShopIt';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductsProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: title,
          theme: ThemeData(
            scaffoldBackgroundColor: Color.fromRGBO(230, 230, 230, 1),
            primarySwatch: Colors.blue,
            accentColor: Colors.purple,
          ),
          routes: {
            AppRoute.ROOT: (_) => TabsRoute(title: title),
            AppRoute.PRODUCTS_DETAIL: (_) => ProductDetailRoute(),
            AppRoute.CART: (_) => CartRoute(),
            AppRoute.ORDERS: (_) => OrdersRoute(),
            AppRoute.ADD_EDIT_USER_PRODUCT: (_) => AddEditUserProductRoute(),
          },
        ),
      );
}
