import 'package:flutter/material.dart';
import 'package:shopit/presentation/orders_overview/orders_route.dart';
import 'package:shopit/presentation/products_overview/products_overview_route.dart';
import 'package:shopit/presentation/user_products/user_products_route.dart';

class TabsRoute extends StatefulWidget {
  final String title;

  const TabsRoute({Key? key, required this.title}) : super(key: key);

  @override
  _TabsRouteState createState() => _TabsRouteState();
}

class _TabsRouteState extends State<TabsRoute> {
  final List<Widget> _routes = [
    ProductsOverviewRoute(),
    OrdersRoute(),
    UserProductsRoute(),
  ];
  int _tabItem = 0;

  void _onTabSelected(int tabItem) {
    setState(() {
      _tabItem = tabItem;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _routes[_tabItem],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabItem,
          onTap: _onTabSelected,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded),
              label: 'Sell',
            ),
          ],
        ),
      );
}
