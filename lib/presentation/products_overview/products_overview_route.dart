import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/auth_provider.dart';
import 'package:shopit/data/provider/cart_provider.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/presentation/cart/cart_route.dart';
import 'package:shopit/presentation/navigation/routes.dart';
import 'package:shopit/presentation/products_overview/badge_widget.dart';
import 'package:shopit/presentation/products_overview/products_widget.dart';
import 'package:shopit/util/custom_route.dart';

enum OptionsMenuItem {
  Favorites,
  All,
  Logout,
}

class ProductsOverviewRoute extends StatefulWidget {
  @override
  _ProductsOverviewRouteState createState() => _ProductsOverviewRouteState();
}

class _ProductsOverviewRouteState extends State<ProductsOverviewRoute> {
  bool _isOnlyFavoritesShown = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = true);
    context.read<ProductsProvider>().fetchProducts(refresh: true).then((_) {
      setState(() => _isLoading = false);
    }).catchError((error) {
      setState(() => _isLoading = false);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text(error.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                  TextButton(
                    onPressed: () => _authorize(context),
                    child: Text('Authorize'),
                  )
                ],
              ));
    });
  }

  void _authorize(BuildContext context) {
    Navigator.of(context).popAndPushNamed(AppRoute.AUTH).then((value) {});
  }

  Future<void> _onOptionItemSelected(OptionsMenuItem item) async {
    if (item == OptionsMenuItem.Logout) {
      await context.read<AuthProvider>().logout();
      return;
    }

    setState(() {
      _isOnlyFavoritesShown = item == OptionsMenuItem.Favorites;
    });
  }

  void _openCart(BuildContext context) {
    // Navigator.of(context).push(
    //   CustomRoute(builder: (builderContext) => CartRoute()),
    // );
    Navigator.of(context).pushNamed(AppRoute.CART);
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await context.read<ProductsProvider>().fetchProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('ShopIt'),
          actions: [
            Consumer<CartProvider>(
              builder: (builderContext, cartProvider, child) => BadgeWidget(
                value: cartProvider.itemCount > 0
                    ? cartProvider.itemCount.toString()
                    : '',
                child: child!,
              ),
              child: IconButton(
              icon: Icon(Icons.shopping_bag_rounded),
              onPressed: () => _openCart(context),
            ),
          ),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (OptionsMenuItem item) => _onOptionItemSelected(item),
            icon: Icon(Icons.more_vert_rounded),
            itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('Show all products'),
                  value: OptionsMenuItem.All,
                ),
                PopupMenuItem(
                  child: Text('Show only favorite products'),
                  value: OptionsMenuItem.Favorites,
                ),
                PopupMenuItem(
                  child: Text('Log Out'),
                  value: OptionsMenuItem.Logout,
                ),
              ],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildProductsWidget(context),
        ),
      );

  Widget _buildProductsWidget(BuildContext context) => ProductsWidget(
        onlyFavorites: _isOnlyFavoritesShown,
      );
}
