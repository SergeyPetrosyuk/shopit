import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopit/data/network/endpoint.dart';
import 'package:shopit/data/network/response_utils.dart';
import 'package:shopit/data/provider/auth_provider.dart';
import 'package:shopit/model/order.dart';

import 'cart_provider.dart';

class OrdersProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  OrdersProvider(this._authProvider, this._orders);

  Future<Uri> _buildUri(String endpoint) async {
    final authToken = _authProvider?.restoreSession();
    return Uri.https(BASE_URL, '$endpoint.json', {'auth': authToken});
  }

  Future<void> fetchOrders({bool refresh = false}) async {
    if (_orders.isNotEmpty && !refresh) return;

    try {
      final uri = await _buildUri(Endpoint.Orders);
      final response = await http.get(uri);
      tryResponseBody(
        response: response,
        responseBodyAction: (data) {
          if (data.isEmpty) {
            _orders = [];
            notifyListeners();
            return;
          }

          final List<Order> orders = [];

          data.forEach((orderId, orderData) {
            final cartItems = (orderData['cart_items'] as List<dynamic>)
                .map((item) => CartItem(
                      id: DateTime.now().toString(),
                      productId: item['product_id'],
                      title: item['title'],
                      price: item['price'] as double,
                      quantity: item['quantity'],
                    ))
                .toList();

            orders.add(Order(
              id: orderId,
              amount: orderData['amount'] as double,
              dateTime: DateTime.parse(orderData['date']),
              items: cartItems,
            ));
          });

          _orders = orders.reversed.toList();
          notifyListeners();
        },
        failureAction: (error) => throw error,
      );
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> items, double amount) async {
    final date = DateTime.now();
    final orderData = jsonEncode({
      'amount': amount,
      'date': date.toIso8601String(),
      'cart_items': items.map((cartItem) => cartItem.toMap()).toList()
    });

    try {
      final uri = await _buildUri(Endpoint.Orders);
      final response = await http.post(uri, body: orderData);

      tryResponseBody(
        response: response,
        responseBodyAction: (data) {
          String? orderId = data['name'];

          if (orderId != null) {
            _orders.add(Order(
              id: orderId,
              amount: amount,
              dateTime: date,
              items: items,
            ));
          }

          notifyListeners();
        },
        failureAction: (error) {
          throw error;
        },
      );
    } catch (error) {
      throw error;
    }
  }
}
