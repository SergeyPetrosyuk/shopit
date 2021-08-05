import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/cart_provider.dart';
import 'package:shopit/data/provider/orders_providers.dart';
import 'package:shopit/presentation/cart/cart_item_widget.dart';

class CartRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.read<OrdersProvider>();
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems.values.toList();

    final Function placeOrderFunc = () {
      ordersProvider.addOrder(cartItems, cartProvider.total);
      cartProvider.clear();
      Navigator.pop(context);
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemBuilder: (_, index) => ChangeNotifierProvider.value(
                value: cartItems[index],
                child: CartItemWidget(),
              ),
              itemCount: cartProvider.itemCount,
            ),
          ),
          _buildCheckoutButton(context, placeOrderFunc),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, Function placeOrderFunc) =>
      Positioned(
        height: 55,
        left: 16,
        right: 16,
        bottom: 32,
        child: ElevatedButton(
          onPressed: () => placeOrderFunc(),
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          child: Text(
            'Checkout',
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );
}
