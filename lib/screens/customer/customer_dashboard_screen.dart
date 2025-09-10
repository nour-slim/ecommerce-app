import 'package:ecommerceapp/providers/auth_provider.dart';
import 'package:ecommerceapp/screens/customer/cart_screen.dart';
import 'package:ecommerceapp/screens/customer/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../catalog/product_detail_screen_customer.dart';
import '../auth/login_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Products"),
            Tab(text: "Cart"),
            Tab(text: "My Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ProductListTab(), CartScreen(), OrderHistoryScreen()],
      ),
    );
  }
}

class ProductListTab extends StatefulWidget {
  @override
  _ProductListTabState createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProducts();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    if (_isLoading) return Center(child: CircularProgressIndicator());

    if (productProvider.products.isEmpty) {
      return Center(child: Text("No products available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: productProvider.products.length,
      itemBuilder: (ctx, index) {
        final product = productProvider.products[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text(
              "\$${product.price.toStringAsFixed(2)} | Stock: ${product.stock}",
            ),
            trailing: product.stock > 0
                ? IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      cartProvider.addItem(product, 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to cart")),
                      );
                    },
                  )
                : const Text(
                    "Out of Stock",
                    style: TextStyle(color: Colors.red),
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
