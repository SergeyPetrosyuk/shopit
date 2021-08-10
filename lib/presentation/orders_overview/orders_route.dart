import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/orders_providers.dart';

import 'order_item_widget.dart';

class OrdersRoute extends StatelessWidget {
  Future<void> _refreshOrders(BuildContext context) async {
    await context.read<OrdersProvider>().fetchOrders(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final futureBody = FutureBuilder(
      future: context.read<OrdersProvider>().fetchOrders(),
      builder: (builderContext, futureState) {
        if (futureState.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        if (futureState.hasError)
          return Center(child: Text(futureState.error.toString()));

        return Consumer<OrdersProvider>(
          builder: (consumerContext, orderData, child) => ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: orderData.orders.length,
            itemBuilder: (_, index) => OrderItemWidget(
              order: orderData.orders[index],
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: RefreshIndicator(
        onRefresh: () => _refreshOrders(context),
        child: futureBody,
      ),
    );
  }
}
