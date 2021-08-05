import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  void _onDismissed(
    BuildContext context,
    DismissDirection direction,
    String productId,
  ) {
    context.read<CartProvider>().removeItem(productId);
  }

  @override
  Widget build(BuildContext context) {
    final CartItem cartItem = context.watch<CartItem>();
    final totalPrice = NumberFormat.simpleCurrency(decimalDigits: 2)
        .format(cartItem.totalPrice);
    return Dismissible(
      key: ValueKey(cartItem.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (builderContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Are you sure?'),
            content: Text('Do you want to remove the item form the cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yep'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _onDismissed(
        context,
        direction,
        cartItem.productId,
      ),
      background: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.centerRight,
            color: Theme.of(context).errorColor,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cartItem.title,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: cartItem.increaseQuantity,
                icon: Icon(Icons.add_rounded),
              ),
              Container(
                width: 30,
                height: 30,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).accentColor,
                  child: Text(
                    cartItem.quantity.toString(),
                    style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.headline6!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: cartItem.decreaseQuantity,
                icon: Icon(Icons.remove_rounded),
              ),
              Chip(
                backgroundColor: Theme.of(context).accentColor,
                label: Text(
                  totalPrice,
                  style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.headline6!.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
