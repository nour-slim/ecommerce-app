import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../catalog/product_detail_screen.dart';
import 'add_product_screen.dart';
import 'admin_orders_screen.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 2) {
        final provider = Provider.of<ProductProvider>(context, listen: false);
        provider.fetchLowStockProducts();
      }
    });
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Admin Dashboard"),
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
              Tab(text: "Add Product"),
              Tab(text: "All Orders"),
              Tab(text: "Low Stock"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AddProductAndListTab(),
            AdminOrdersScreen(),
            LowStockTab(),
          ],
        ),
      ),
    );
  }
}

class AddProductAndListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<ProductProvider>(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(flex: 1, child: AddProductScreen()),
            SizedBox(height: 12),
            Expanded(flex: 1, child: ProductListWidget()),
          ],
        ),
      ),
    );
  }
}

class ProductListWidget extends StatefulWidget {
  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts().then((
      _,
    ) {
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    if (_isLoading) return Center(child: CircularProgressIndicator());

    if (productProvider.products.isEmpty)
      return Center(child: Text("No products yet"));

    return ListView.builder(
      itemCount: productProvider.products.length,
      itemBuilder: (ctx, index) {
        final product = productProvider.products[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
            trailing: Text(
              product.stock > 0 ? "In Stock" : "Out of Stock",
              style: TextStyle(
                color: product.stock > 0 ? Colors.green : Colors.red,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: product.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class LowStockTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    if (provider.lowStockProducts.isEmpty) {
      return Center(child: Text("No low-stock products"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.lowStockProducts.length,
      itemBuilder: (ctx, index) {
        final product = provider.lowStockProducts[index];
        return Card(
          child: ListTile(
            title: Text(product.name),
            subtitle: Text('Stock: ${product.stock}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: product.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
