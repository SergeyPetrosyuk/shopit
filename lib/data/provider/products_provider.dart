import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopit/data/network/endpoint.dart';
import 'package:shopit/model/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
      'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  List<Product> get products => [..._products];

  List<Product> get favoriteProducts =>
      _products.where((product) => product.isFavorite).toList();

  Product findById(String id) =>
      _products.firstWhere((product) => product.id == id);

  void toggleFavorite(String id) {
    _products.firstWhere((product) => product.id == id).toggleFavorite();
  }

  Future<void> updateProduct(
    String id,
    String title,
    String description,
    String imageUrl,
    double price,
  ) {
    final int index = _products.indexWhere((element) => element.id == id);
    final productJsonData = jsonEncode({
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'favorite': _products[index].isFavorite,
    });

    return http
        .patch(_buildUri(productId: id), body: productJsonData)
        .then((response) {
      if (_isResponseSuccess(response)) {
        final product = Product(
          id: id,
          title: title,
          description: description,
          price: price,
          imageUrl: imageUrl,
          isFavorite: _products[index].isFavorite,
        );

        _products[index] = product;
        notifyListeners();
      } else {
        throw response.body;
      }
    });
  }

  Future<void> addProduct(
    String title,
    String description,
    String imageUrl,
    double price,
  ) {
    final productJsonData = jsonEncode({
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'favorite': false,
    });

    return http.post(_buildUri(), body: productJsonData).then((response) {
      if (_isResponseSuccess(response)) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData.containsKey('name')) {
            final product = Product(
              id: responseData['name']!,
              title: title,
              description: description,
              price: price,
              imageUrl: imageUrl,
              isFavorite: false,
            );

            _products.insert(0, product);
            notifyListeners();
          }
        }
      } else {
        throw response.body;
      }
    });
  }

  void delete(String productId) {
    _products.removeWhere((element) => element.id == productId);
    notifyListeners();
  }

  bool _isResponseSuccess(http.Response response) =>
      response.statusCode >= 200 && response.statusCode < 300;

  Uri _buildUri({String productId = ''}) {
    final endpoint = productId.isNotEmpty ? '/$productId' : '';
    final uri = Uri.https(BASE_URL, '${Endpoint.Products}$endpoint.json');
    print(uri);
    return uri;
  }
}
