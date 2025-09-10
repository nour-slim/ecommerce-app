import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminOrdersScreen extends StatefulWidget {
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List orders = [];
  bool loading = true;

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/orders/all'),
      );
      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch orders')));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Orders')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = order['items'] as List<dynamic>;
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text('Order #${order['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${order['customerEmail']}'),
                        Text('Total: \$${order['total']}'),
                        Text('Date: ${order['date'].split('T')[0]}'),
                      ],
                    ),
                    children: items
                        .map(
                          (item) => ListTile(
                            title: Text(item['productName']),
                            subtitle: Text(
                              'Qty: ${item['quantity']} × \$${item['price']}',
                            ),
                            trailing: Text(
                              '\$${(item['quantity'] * item['price']).toStringAsFixed(2)}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
    );
  }
}
