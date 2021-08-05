import 'package:flutter/material.dart';
import 'package:shopit/model/order.dart';

import 'cart_provider.dart';

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  void addOrder(List<CartItem> items, double amount) {
    _orders.insert(
      0,
      Order(
        id: DateTime.now().toString(),
        amount: amount,
        dateTime: DateTime.now(),
        items: items,
      ),
    );
    notifyListeners();
  }
}
