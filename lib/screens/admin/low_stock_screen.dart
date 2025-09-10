import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LowStockScreen extends StatefulWidget {
  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  List products = [];
  bool loading = true;

  Future<void> fetchLowStock() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/products/admin/low-stock'),
    );
    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch low stock items')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLowStock();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  title: Text(product['name']),
                  subtitle: Text('Stock: ${product['stock']}'),
                ),
              );
            },
          );
  }
}
