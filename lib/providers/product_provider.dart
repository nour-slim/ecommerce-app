import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  List<Product> _lowStockProducts = [];
  List<Product> get lowStockProducts => _lowStockProducts;

  final String baseUrl = 'http://localhost:8080';

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _products = data.map((item) => Product.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index >= 0) {
          _products[index] = Product.fromJson(json.decode(response.body));
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
    }
  }

  /* Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        _products.add(Product.fromJson(json.decode(response.body)));
        notifyListeners();
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      debugPrint('Error adding product: $e');
    }
  } */

  Future<void> fetchLowStockProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/admin/low-stock'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _lowStockProducts = data.map((item) => Product.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching low-stock products: $e");
    }
  }

  Product? getById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
