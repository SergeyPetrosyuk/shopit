import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/cart_provider.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/model/product.dart';
import 'package:shopit/presentation/navigation/routes.dart';

class ProductItem extends StatelessWidget {
  void _onItemTapped(BuildContext context, String id) {
    Navigator.of(context).pushNamed(AppRoute.PRODUCTS_DETAIL, arguments: id);
  }

  void _addToCart(BuildContext context, Product product) {
    final cartProvider = context.read<CartProvider>();
    cartProvider.add(product.id, product.title, product.price);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item has been added to cart'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => cartProvider.removeSingleItem(product.id),
        ),
      ),
    );
  }

  void _toggleFavorite(
    ProductsProvider provider,
    ScaffoldMessengerState messengerState,
    String productId,
  ) async {
    try {
      await provider.toggleFavorite(productId);
    } catch (error) {
      messengerState.showSnackBar(SnackBar(
        content: Text(error.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<Product>();
    final provider = context.read<ProductsProvider>();
    final messengerState = ScaffoldMessenger.of(context);

    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildImageWidget(
              context,
              product.imageUrl,
              product.id,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 2,
                  child: _buildTitleWidget(context, product.title),
                ),
                Flexible(
                  flex: 1,
                  child: Consumer<Product>(
                    builder: (builderContext, p, child) => IconButton(
                      onPressed: () => _toggleFavorite(
                        provider,
                        messengerState,
                        product.id,
                      ),
                      icon: Icon(p.isFavorite
                          ? Icons.star_rate_rounded
                          : Icons.star_border_rounded),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    onPressed: () => _addToCart(context, product),
                    icon: Icon(Icons.add_shopping_cart_rounded),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: _buildPriceWidget(context, product.price),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildImageWidget(
    BuildContext context,
    String imageUrl,
    String productId,
  ) =>
      ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    onTap: () => _onItemTapped(context, productId),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ));

  Widget _buildTitleWidget(BuildContext context, String title) => Container(
        padding: EdgeInsets.all(16),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );

  Widget _buildPriceWidget(BuildContext context, double price) => Container(
        padding: EdgeInsets.all(16),
        child: Text(
          '${NumberFormat.simpleCurrency(decimalDigits: 2).format(price)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
}
