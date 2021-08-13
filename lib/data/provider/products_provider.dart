import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopit/data/network/endpoint.dart';
import 'package:shopit/data/network/response_utils.dart';
import 'package:shopit/model/http_exception.dart';
import 'package:shopit/model/product.dart';

import 'auth_provider.dart';

class ProductsProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  List<Product> _products = [];

  List<Product> get products => [..._products];

  List<Product> get favoriteProducts =>
      _products.where((product) => product.isFavorite).toList();

  ProductsProvider(this._authProvider, this._products);

  Product findById(String id) =>
      _products.firstWhere((product) => product.id == id);

  Future<void> toggleFavorite(String id) async {
    final Product product = _products.firstWhere((product) => product.id == id);
    product.toggleFavorite();

    final patchData = jsonEncode({'favorite': product.isFavorite});
    final url = await _buildUri(productId: id);

    try {
      final response = await http.patch(url, body: patchData);
      if (!isResponseSuccess(response)) throw HttpExceptions(response);
    } catch (error) {
      product.toggleFavorite();
      throw error;
    }
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (_products.isNotEmpty && !refresh) return;

    try {
      final uri = await _buildUri();
      final response = await http.get(uri);

      tryResponseBody(
        response: response,
        failureAction: (error) => throw error,
        responseBodyAction: (data) {
          if (data.isEmpty) {
            _products = [];
            notifyListeners();
            return;
          }

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
      throw error;
    }
  }

  Future<void> updateProduct(String id,
      String title,
      String description,
      String imageUrl,
      double price,) async {
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
      final uri = await _buildUri(productId: id);
      final response = await http.patch(uri, body: productJsonData);

      if (isResponseSuccess(response)) {
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

  Future<void> addProduct(String title,
      String description,
      String imageUrl,
      double price,) async {
    final productJsonData = jsonEncode({
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'favorite': false,
    });

    try {
      final uri = await _buildUri();
      final response = await http.post(uri, body: productJsonData);

      if (isResponseSuccess(response)) {
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

    final url = await _buildUri(productId: productId);

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

  Future<Uri> _buildUri({String productId = ''}) async {
    final endpoint = productId.isNotEmpty ? '/$productId' : '';
    final String? authToken = _authProvider?.restoreSession();
    final uri = Uri.https(
      BASE_URL,
      '${Endpoint.Products}$endpoint.json',
      {'auth': authToken},
    );
    print(uri);
    return uri;
  }
}
