import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopit/model/order.dart';

class OrderItemWidget extends StatefulWidget {
  final Order order;

  const OrderItemWidget({Key? key, required this.order}) : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final orderAmount = NumberFormat.simpleCurrency(decimalDigits: 2)
        .format(widget.order.amount);

    final date = DateFormat.MMMMEEEEd().add_Hm().format(widget.order.dateTime);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(orderAmount),
            subtitle: Text(date),
            trailing: IconButton(
              icon: Icon(_expanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 350),
            height: _expanded ? widget.order.items.length * 30 + 16 : 0,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (_, index) {
                final item = widget.order.items[index];
                final amount = NumberFormat.simpleCurrency(decimalDigits: 2)
                    .format(item.price);
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 30,
                  width: double.infinity,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.title),
                        Text(
                          '${item.quantity} x $amount',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      ],
                    ),
                  );
                },
                itemCount: widget.order.items.length,
              ),
            ),
        ],
      ),
    );
  }
}
