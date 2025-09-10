import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final product = productProvider.getById(widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Product Not Found")),
        body: Center(child: Text("This product does not exist.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 10),
            Text(
              "Stock: ${product.stock}",
              style: TextStyle(
                fontSize: 16,
                color: product.stock > 0 ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              product.description.isNotEmpty
                  ? product.description
                  : "No description available",
            ),
            SizedBox(height: 20),
            loading
                ? Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.edit),
                        label: Text('Update'),
                        onPressed: () async {
                          final updatedProduct = await showDialog<Product>(
                            context: context,
                            builder: (ctx) {
                              final nameController = TextEditingController(
                                text: product.name,
                              );
                              final priceController = TextEditingController(
                                text: product.price.toString(),
                              );
                              final stockController = TextEditingController(
                                text: product.stock.toString(),
                              );
                              final descController = TextEditingController(
                                text: product.description,
                              );

                              return AlertDialog(
                                title: Text('Update Product'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                        ),
                                      ),
                                      TextField(
                                        controller: priceController,
                                        decoration: InputDecoration(
                                          labelText: 'Price',
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextField(
                                        controller: stockController,
                                        decoration: InputDecoration(
                                          labelText: 'Stock',
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextField(
                                        controller: descController,
                                        decoration: InputDecoration(
                                          labelText: 'Description',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final updated = Product(
                                        id: product.id,
                                        name: nameController.text,
                                        price:
                                            double.tryParse(
                                              priceController.text,
                                            ) ??
                                            product.price,
                                        stock:
                                            int.tryParse(
                                              stockController.text,
                                            ) ??
                                            product.stock,
                                        description: descController.text,
                                      );
                                      Navigator.of(ctx).pop(updated);
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (updatedProduct != null) {
                            setState(() => loading = true);
                            try {
                              await productProvider.updateProduct(
                                updatedProduct,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Product updated successfully'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            } finally {
                              setState(() => loading = false);
                            }
                          }
                        },
                      ),

                      ElevatedButton.icon(
                        icon: Icon(Icons.delete),
                        label: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Delete Product'),
                              content: Text(
                                'Are you sure you want to delete ${product.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            setState(() => loading = true);
                            try {
                              await productProvider.deleteProduct(product.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Product deleted successfully'),
                                ),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            } finally {
                              setState(() => loading = false);
                            }
                          }
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
