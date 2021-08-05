import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/orders_providers.dart';

import 'order_item_widget.dart';

class OrdersRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: ordersProvider.orders.length,
        itemBuilder: (_, index) => OrderItemWidget(
          order: ordersProvider.orders[index],
        ),
      ),
    );
  }
}
