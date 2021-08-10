import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/model/product.dart';
import 'package:shopit/presentation/navigation/routes.dart';
import 'package:shopit/presentation/user_products/user_product_item_widget.dart';

class UserProductsRoute extends StatelessWidget {
  void _navigateToProductEditing(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoute.ADD_EDIT_USER_PRODUCT);
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await context.read<ProductsProvider>().fetchProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();
    final List<Product> products = productsProvider.products;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          products.isNotEmpty
              ? IconButton(
            onPressed: () => _navigateToProductEditing(context),
            icon: Icon(Icons.add_rounded),
          )
              : Container(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: products.isEmpty
            ? _buildEmptyListWidget(context)
            : _buildProductListWidget(context, products),
      ),
    );
  }

  Widget _buildProductListWidget(
    BuildContext context,
    List<Product> products,
  ) =>
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (_, index) => Column(
          children: [
            UserProductItemWidget(
              id: products[index].id,
              title: products[index].title,
              imageUrl: products[index].imageUrl,
            ),
            index < (products.length - 1) ? Divider() : Container(),
          ],
        ),
      );

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
              onPressed: () => _navigateToProductEditing(context),
              child: Text('Add Product'),
            ),
          ],
        ),
      );
}
