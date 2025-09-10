import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  bool _isFetchingOrders = false;

  List<CartItem> get items => List.unmodifiable(_items);
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void addItem(Product product, int quantity) {
    if (quantity <= 0) return;

    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final newQuantity = _items[existingIndex].quantity + quantity;
      if (newQuantity <= product.stock) {
        _items[existingIndex] = CartItem(
          product: product,
          quantity: newQuantity,
        );
        notifyListeners();
      }
    } else {
      if (quantity <= product.stock) {
        _items.add(CartItem(product: product, quantity: quantity));
        notifyListeners();
      }
    }
  }

  void updateQuantity(Product product, int newQuantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else if (newQuantity <= product.stock) {
        _items[index] = CartItem(product: product, quantity: newQuantity);
      }
      notifyListeners();
    }
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> placeOrder(String userEmail) async {
    if (_items.isEmpty) throw Exception('Cart is empty');

    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'items': _items.map((item) => item.toJson()).toList(),
          'total': total,
          'customerEmail': userEmail,
        }),
      );

      if (response.statusCode == 201) {
        _items.clear();
        await fetchOrders(userEmail);
      } else {
        throw Exception(
          'Failed to place order: ${response.statusCode} - ${response.body}',
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchOrders(String userEmail) async {
    if (userEmail.isEmpty) throw Exception('Email is required');
    if (_isFetchingOrders) return;

    _isFetchingOrders = true;
    _setLoading(true);

    try {
      final encodedEmail = Uri.encodeComponent(userEmail);
      final response = await http.get(
        Uri.parse('http://localhost:8080/orders/customer/$encodedEmail'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _orders = data.map((json) => Order.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    } finally {
      _isFetchingOrders = false;
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  CartItem? getItem(Product product) {
    try {
      return _items.firstWhere((item) => item.product.id == product.id);
    } catch (e) {
      return null;
    }
  }
}
