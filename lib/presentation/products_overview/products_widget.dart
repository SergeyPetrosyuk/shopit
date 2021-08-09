import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/presentation/navigation/routes.dart';
import 'package:shopit/presentation/products_overview/product_item_widget.dart';

class ProductsWidget extends StatelessWidget {
  final bool onlyFavorites;

  ProductsWidget({required this.onlyFavorites});

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();
    final products = onlyFavorites
        ? productsProvider.favoriteProducts
        : productsProvider.products;

    return products.isEmpty
        ? _buildEmptyListWidget(context)
        : ListView.builder(
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

  Widget _buildEmptyListWidget(BuildContext context) => Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'You don\'t have products yet',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoute.ADD_EDIT_USER_PRODUCT);
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      );
}
