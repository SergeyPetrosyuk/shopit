import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/cart_provider.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/presentation/navigation/routes.dart';
import 'package:shopit/presentation/products_overview/badge_widget.dart';
import 'package:shopit/presentation/products_overview/products_widget.dart';

enum OptionsMenuItem {
  Favorites,
  All,
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
    context.read<ProductsProvider>().fetchProducts().then((_) {
      setState(() => _isLoading = false);
    });
  }

  void _onOptionItemSelected(OptionsMenuItem item) {
    setState(() {
      _isOnlyFavoritesShown = item == OptionsMenuItem.Favorites;
    });
  }

  void _openCart(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoute.CART);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildProductsWidget(context),
    );
  }

  Widget _buildProductsWidget(BuildContext context) => ProductsWidget(
        onlyFavorites: _isOnlyFavoritesShown,
      );
}
