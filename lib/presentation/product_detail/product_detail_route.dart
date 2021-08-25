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
      // appBar: AppBar(
      //   title: Text(product.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(product.title),
                background: Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 16),
              Center(
                child: Text(
                  price,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(product.description, softWrap: true),
              )
            ]),
          )
        ],
      ),
    );
  }
}
