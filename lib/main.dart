import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopit/data/provider/auth_provider.dart';
import 'package:shopit/data/provider/cart_provider.dart';
import 'package:shopit/data/provider/orders_providers.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/presentation/auth/auth_route.dart';
import 'package:shopit/presentation/cart/cart_route.dart';
import 'package:shopit/presentation/navigation/routes.dart';
import 'package:shopit/presentation/orders_overview/orders_route.dart';
import 'package:shopit/presentation/product_detail/product_detail_route.dart';
import 'package:shopit/presentation/tabs/tabs_route.dart';
import 'package:shopit/presentation/user_products/add_edit_user_product_route.dart';
import 'package:shopit/util/custom_route.dart';

Future main() async {
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  final String title = 'ShopIt';
  final SharedPreferences _prefs;

  const MyApp(this._prefs);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(_prefs)),
          ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
            update: (_, authProvider, productsProvider) {
              return ProductsProvider(
                authProvider,
                productsProvider == null ? [] : productsProvider.products,
              );
            },
            create: (_) => ProductsProvider(null, []),
          ),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
              update: (_, authProvider, orderProvider) => OrdersProvider(
                    authProvider,
                    orderProvider == null ? [] : orderProvider.orders,
                  ),
              create: (_) => OrdersProvider(null, [])),
        ],
        child: Consumer<AuthProvider>(
          builder: (builderContext, authProvider, _) =>
              _buildAppWidget(context, authProvider),
        ),
      );

  Widget _buildAppWidget(BuildContext context, AuthProvider authProvider) {
    authProvider.restoreSession();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(230, 230, 230, 1),
        primarySwatch: Colors.blue,
        accentColor: Colors.purple,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CustomRouteTransitionBuilder(),
        }),
      ),
      home: authProvider.sessionActive ? TabsRoute(title: title) : AuthRoute(),
      routes: {
        AppRoute.PRODUCTS_DETAIL: (_) => ProductDetailRoute(),
          AppRoute.CART: (_) => CartRoute(),
          AppRoute.ORDERS: (_) => OrdersRoute(),
          AppRoute.ADD_EDIT_USER_PRODUCT: (_) => AddEditUserProductRoute(),
          AppRoute.AUTH: (_) => AuthRoute(),
        },
      );
  }
}
