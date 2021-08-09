import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopit/data/network/endpoint.dart';
import 'package:shopit/model/http_exception.dart';
import 'package:shopit/model/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => [..._products];

  List<Product> get favoriteProducts =>
      _products.where((product) => product.isFavorite).toList();

  Product findById(String id) =>
      _products.firstWhere((product) => product.id == id);

  Future<void> toggleFavorite(String id) async {
    final Product product = _products.firstWhere((product) => product.id == id);
    product.toggleFavorite();

    final patchData = jsonEncode({'favorite': product.isFavorite});
    final url = _buildUri(productId: id);

    try {
      final response = await http.patch(url, body: patchData);
      if (!_isResponseSuccess(response)) throw HttpExceptions(response);
    } catch (error) {
      product.toggleFavorite();
      throw error;
    }
  }

  void _tryResponseBody({
    required http.Response response,
    required Function(Map<String, dynamic>) responseBodyAction,
    Function(Exception exception)? failureAction,
  }) {
    if (!_isResponseSuccess(response)) {
      failureAction?.call(Exception(response.body));
      return;
    }

    if (response.body.toLowerCase() == 'null') {
      responseBodyAction({});
      return;
    }

    responseBodyAction(jsonDecode(response.body));
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (_products.isNotEmpty && !refresh) return;

    print('fetchProducts()');
    final uri = Uri.https(BASE_URL, '${Endpoint.Products}.json');

    try {
      final response = await http.get(uri);

      _tryResponseBody(
        response: response,
        failureAction: (error) => throw error,
        responseBodyAction: (data) {
          final List<Product> products = [];
          data.forEach((id, productData) {
            products.add(Product(
              id: id,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              imageUrl: productData['image_url'],
              isFavorite: productData['favorite'],
            ));
          });

          _products = products;
          notifyListeners();
        },
      );
    } catch (error) {
      print('catch::$error');
      // throw error;
    }
  }

  Future<void> updateProduct(
    String id,
    String title,
    String description,
    String imageUrl,
    double price,
  ) async {
    final int index = _products.indexWhere((element) => element.id == id);
    final productJsonData = jsonEncode({
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'favorite': _products[index].isFavorite,
    });

    try {
      final response = await http.patch(
        _buildUri(productId: id),
        body: productJsonData,
      );

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
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(
    String title,
    String description,
    String imageUrl,
    double price,
  ) async {
    final productJsonData = jsonEncode({
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'favorite': false,
    });

    try {
      final response = await http.post(_buildUri(), body: productJsonData);

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

            _products.add(product);
            notifyListeners();
          }
        }
      } else {
        throw response.body;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> delete(String productId) async {
    final productIndex =
        _products.indexWhere((element) => element.id == productId);

    if (productIndex == -1) return;

    Product? product = _products[productIndex];

    _products.removeAt(productIndex);
    notifyListeners();

    final url = _buildUri(productId: productId);

    Function fallbackAction = (){
      _products.insert(productIndex, product!);
      notifyListeners();
    };

    final response = await http.delete(url);
    if(response.statusCode >= 400) {
      fallbackAction();
      throw HttpExceptions(response);
    }
    product = null;
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
