import 'package:flutter/material.dart';

class CartItem with ChangeNotifier {
  final String id;
  final String productId;
  final String title;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    this.quantity = 0,
  });

  Map<String, Object> toMap() => {
        'product_id': productId,
        'title': title,
        'price': price,
        'quantity': quantity,
      };

  void increaseQuantity() {
    quantity += 1;
    notifyListeners();
  }

  void decreaseQuantity() {
    quantity -= 1;
    if (quantity < 1) quantity = 1;
    notifyListeners();
  }

  double get totalPrice => quantity * price;
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems => {..._cartItems};

  int get itemCount => _cartItems.length;

  double get total {
    var total = 0.0;
    _cartItems.forEach((key, cartItem) {
      total += (cartItem.quantity * cartItem.price);
    });

    return total;
  }

  CartItem? getByProductId(String productId) => _cartItems[productId];

  void add(
    String productId,
    String title,
    double price,
  ) {
    _cartItems.containsKey(productId)
        ? _updateProduct(productId, title, price)
        : _addProduct(productId, title, price);

    notifyListeners();
  }

  void _addProduct(
    String productId,
    String title,
    double price,
  ) {
    _cartItems.putIfAbsent(
      productId,
      () => CartItem(
        id: DateTime.now().toString(),
        productId: productId,
        title: title,
        price: price,
        quantity: 1,
      ),
    );
  }

  void _updateProduct(
    String productId,
    String title,
    double price,
  ) {
    _cartItems[productId]?.increaseQuantity();
  }

  void removeItem(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void clear() {
    _cartItems = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (_cartItems.containsKey(productId)) {
      final CartItem? cartItem = _cartItems[productId];
      if (cartItem == null) {
        return;
      }

      if(cartItem.quantity > 1){
        cartItem.decreaseQuantity();
      } else {
        _cartItems.remove(productId);
        notifyListeners();
      }
    }
  }
}
