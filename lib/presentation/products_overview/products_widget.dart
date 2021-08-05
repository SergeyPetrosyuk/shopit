import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/cart_provider.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/presentation/products_overview/product_item_widget.dart';

class ProductsWidget extends StatelessWidget {
  final bool onlyFavorites;

  ProductsWidget({required this.onlyFavorites});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final productsProvider = context.watch<ProductsProvider>();
    final cartItems = cartProvider.cartItems;
    final products = onlyFavorites
        ? productsProvider.favoriteProducts
        : productsProvider.products;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: products.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: ChangeNotifierProvider.value(
          value: products[index],
          child: ProductItem(),
        ),
      ),
    );
  }
}
