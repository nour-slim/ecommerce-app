import 'package:ecommerceapp/models/order.dart';
import 'package:ecommerceapp/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Future<void>? _ordersFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (_ordersFuture == null && authProvider.userEmail != null) {
      _ordersFuture = cartProvider.fetchOrders(authProvider.userEmail!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.userEmail == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Order History')),
        body: Center(child: Text('Please login to view your orders')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (cartProvider.orders.isEmpty) {
            return Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: cartProvider.orders.length,
            itemBuilder: (ctx, index) {
              final order = cartProvider.orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text('Order #${order.id}'),
        subtitle: Text('Total: \$${order.total.toStringAsFixed(2)}'),
        trailing: Text(order.date.toLocal().toString().split(' ')[0]),
        children: order.items
            .map(
              (item) => ListTile(
                title: Text(item.name),
                subtitle: Text(
                  'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                ),
                trailing: Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
