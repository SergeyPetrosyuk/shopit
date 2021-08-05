import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/products_provider.dart';

class ProductDetailRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final product = context.read<ProductsProvider>().findById(productId);
    final price =
        NumberFormat.simpleCurrency(decimalDigits: 2).format(product.price);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(price, style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(product.description, softWrap: true),
            )
          ],
        ),
      ),
    );
  }
}
