import 'package:flutter/cupertino.dart';
import 'package:shopit/data/provider/cart_provider.dart';

class Order with ChangeNotifier {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItem> items;

  Order({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.items,
  });
}
